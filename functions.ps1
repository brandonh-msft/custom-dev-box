function Write-Status
{
    process
    {
        if ($_.Status -eq 'Ok')
        {
            Write-Output "`u{2713}"
        }
        else
        {
            Write-Output "$($_.Status) $($_.ExtendedErrorCode)"
        }
    }
}

function Install-PackageWithStatus (
    [Parameter(Mandatory = $true)]
    [string]$packageName,
    [Parameter(Mandatory = $true)]
    [string]$packageId,
    [switch]$user,
    [switch]$cli
)
{
    Start-WithStatus "Installing $packageName" {
        try
        {
            if ($user)
            {
                if ($cli)
                {
                    winget install --accept-package-agreements --accept-source-agreements --disable-interactivity --id $packageId -h --scope user
                }
                else
                {
                    Install-WinGetPackage -Scope UserOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id $packageId | Write-Status 
                }
            }
            else
            {
                if ($cli)
                {
                    winget install --accept-package-agreements --accept-source-agreements --disable-interactivity --id $packageId -h --scope machine
                }
                else
                {
                    Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id $packageId | Write-Status
                }
            } 
        }
        catch
        {
            Write-Error "Error installing '$packageName': $($_.Exception.Message)"
        }
    }
}

function Start-WithStatus (
    [Parameter(Mandatory = $true)]
    [string]$status,
    [Parameter(Mandatory = $true)]
    [scriptblock]$scriptBlock
)
{
    Write-Host "$status..."
    & $scriptBlock
    Write-Host "$status - Done."
}

function UnpinFrom-Taskbar ([string]$appname)
{
    try
    {
        ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object { $_.Name -eq $appname }).Verbs() | Where-Object { $_.Name.replace('&', '') -match 'Unpin from Taskbar' } | ForEach-Object { $_.DoIt() }
        return "App '$appname' unpinned from Taskbar"
    }
    catch
    {
        Write-Error "Error Unpinning '$appname': $($_.Exception.Message)"
    }
}
  
function Set-RegistryKeyValue([string]$keyPath, [string]$valueName, [string]$valueData)
{
    try
    {
        Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData
        return "Registry key '$keyPath' value '$valueName' set to '$valueData'"
    }
    catch
    {
        Write-Error "Error setting registry key '$keyPath' value '$valueName' to '$valueData': $($_.Exception.Message)"
    }
}