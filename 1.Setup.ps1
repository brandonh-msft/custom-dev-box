. $PSScriptRoot\functions.ps1

Write-Output "Powershell edition: $($PSVersionTable.PSEdition)"

Start-WithStatus "Applying Timezone Redirecting settings" { & $PSScriptRoot\Set-TimezoneRedirection.ps1 }
Start-WithStatus "Applying Windows Optimizations" { & $PSScriptRoot\Set-WindowsOptimization.ps1 -Optimizations 'WindowsMediaPlayer', 'ScheduledTasks', 'DefaultUserSettings', 'Autologgers', 'Services', 'NetworkOptimizations', 'LGPO', 'Edge', 'RemoveLegacyIE' }
Start-WithStatus "Creating DevDrive" { 
    & $PSScriptRoot\Create-DevDrive.ps1 -DriveLetter 'E' # Because D is already taken by the DVD drive
}

try
{
    Write-Host "Checking for PowerShell Core..."

    pwsh -v

    Write-Host "PowerShell Core is installed."
}
catch
{
    Write-Host "PowerShell Core is not installed. Installing ..."
    Start-WithStatus "Installing PowerShell Core" {
        # Get the latest download URL
        $URL = Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
        $URL = $URL.assets.browser_download_url -match 'win-x64.msi'

        Write-Output "Downloading $URL ..."

        # Define the destination
        $destination = "$env:TEMP\\PowerShell-latest.msi"

        Invoke-WebRequest -Uri "$URL" -OutFile $destination

        Start-Process -FilePath msiexec.exe -ArgumentList "/i $destination /qn /norestart" -Wait -NoNewWindow

        Remove-Item $destination
    }
}