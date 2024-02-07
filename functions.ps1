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
                    ($psResult = Install-WinGetPackage -Scope UserOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id $packageId) | Write-Status 
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
                    ($psResult = Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id $packageId) | Write-Status
                }
            }

            if ($cli -and $LASTEXITCODE -ne 0)
            {
                Write-Warning "WinGet CLI returned exit code $LASTEXITCODE - attempting install without scope"
                winget install --accept-package-agreements --accept-source-agreements --disable-interactivity --id $packageId -h
            }
            elseif (-not $cli -and $psResult.Status -ne 'Ok')
            {
                Write-Warning "WinGet Powershell returned status '$($psResult.Status)' - attempting install with CLI"
                if ($user)
                {
                    Install-PackageWithStatus -packageName $packageName -packageId $packageId -cli -user
                }
                else
                {
                    Install-PackageWithStatus -packageName $packageName -packageId $packageId -cli
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
    & $scriptBlock > $null
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
  
function Set-RegistryKeyValue([string]$Path, [string]$Name, $Value) {
    try {
        if (!(Test-Path $Path)) {
            $regKey = New-Item -Path $Path
        }
        else {
            $regKey = Get-Item -Path $Path
        }
    
        $regKey | Set-ItemProperty -Name $Name -Value $Value -Force > $null

        return "Registry key '$Path' value '$Name' set to '$Value'"
    }
    catch {
        Write-Error "Error setting registry key '$Path' value '$Name' to '$Value': $($_.Exception.Message)"
    }
}