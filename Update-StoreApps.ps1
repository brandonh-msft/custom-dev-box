<#
.SYNOPSIS
    Synchronously triggers store updates for a select set of apps. You should run this in
    legacy powershell.exe, as some of the code has problems in pwsh on older OS releases.
#>
[CmdletBinding()]
param()

try
{
    if ($PSVersionTable.PSVersion.Major -ne 5)
    {
        throw "This script has problems in pwsh on some platforms; please run it with legacy Windows PowerShell (5.1) (powershell.exe)."
    }

    # https://fleexlab.blogspot.com/2018/02/using-winrts-iasyncoperation-in.html
    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
    function Await($WinRtTask, $ResultType) {
        $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
        $netTask = $asTask.Invoke($null, @($WinRtTask))
        $netTask.Wait(-1) | Out-Null
        $netTask.Result
    }

    # https://docs.microsoft.com/uwp/api/windows.applicationmodel.store.preview.installcontrol.appinstallmanager?view=winrt-22000
    # We need to tell PowerShell about this WinRT API before we can call it...
    Write-Host "Enabling Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallManager WinRT type"
    [Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallManager,Windows.ApplicationModel.Store.Preview,ContentType=WindowsRuntime] | Out-Null
    $appManager = New-Object -TypeName Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallManager

    # Customize this list of apps to suit... the key one for making sure that winget.exe is
    # installed is the DesktopAppInstaller one.
    $appsToUpdate = @(
        "Microsoft.WindowsTerminal_8wekyb3d8bbwe",
        "Microsoft.WindowsCalculator_8wekyb3d8bbwe",
        "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe",  # <-- winget comes from this one
        "Microsoft.WindowsNotepad_8wekyb3d8bbwe",
        "Microsoft.Paint_8wekyb3d8bbwe",
        "Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe",
        "MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy",
        "Microsoft.WindowsStore_8wekyb3d8bbwe"
    )

    foreach ($app in $appsToUpdate)
    {
        try
        {
            Write-Host "Requesting an update for $app..."
            $updateOp = $appManager.UpdateAppByPackageFamilyNameAsync($app)
            $updateResult = Await $updateOp ([Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallItem])
            while ($true)
            {
                if ($null -eq $updateResult)
                {
                    Write-Host "Update is null. It must already be completed (or there was no update)..."
                    break
                }

                if ($null -eq $updateResult.GetCurrentStatus())
                {
                    Write-Host "Current status is null. WAT"
                    break
                }

                Write-Host $updateResult.GetCurrentStatus().PercentComplete
                if ($updateResult.GetCurrentStatus().PercentComplete -eq 100)
                {
                    Write-Host "Install completed ($app)"
                    break
                }
                Start-Sleep -Seconds 3
            }
        }
        catch [System.AggregateException]
        {
            # If the thing is not installed, we can't update it. In this case, we get an
            # ArgumentException with the message "Value does not fall within the expected
            # range." I cannot figure out why *that* is the error in the case of "app is
            # not installed"... perhaps we could be doing something different/better, but
            # I'm happy to just let this slide for now.
            $problem = $_.Exception.InnerException # we'll just take the first one
            Write-Host "Error updating app $app : $problem"
            Write-Host "(this is expected if the app is not installed; you can probably ignore this)"
        }
        catch
        {
            Write-Host "Unexpected error updating app $app : $_"
        }
    }

    Write-Host "Store updates completed"

}
catch
{
    Write-Error "Problem updating store apps: $_"
}