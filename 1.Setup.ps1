Write-Output "Powershell edition: $($PSVersionTable.PSEdition)"

Write-Host "Applying Timezone Redirecting settings"
& $PSScriptRoot\Set-TimezoneRedirection.ps1
Write-Host "Applying Timezone Redirecting settings - Done."

Write-Host "Applying Windows Optimizations"
& $PSScriptRoot\Set-WindowsOptimization.ps1 -Optimizations 'WindowsMediaPlayer', 'ScheduledTasks', 'DefaultUserSettings', 'Autologgers', 'Services', 'NetworkOptimizations', 'LGPO', 'Edge', 'RemoveLegacyIE'
Write-Host "Applying Windows Optimizations - Done."

Write-Host "Creating DevDrive"
& $PSScriptRoot\Create-DevDrive.ps1 -DriveLetter 'E' # Because D is already taken by the DVD drive
Write-Host "Creating DevDrive - Done."

Write-Host "Removing DVD drive from the system"
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\cdrom -Name Start -Value 4 -Type DWord
Write-Host "Removing DVD drive from the system - Done."

try {
    Write-Host "Checking for PowerShell Core..."

    pwsh -v

    Write-Host "PowerShell Core is installed."
}
catch {
    Write-Host "PowerShell Core is not installed. Installing ..."

    # Get the latest download URL
    $URL = Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
    $URL = $URL.assets.browser_download_url -match 'win-x64.msi'

    Write-Output "Downloading $URL ..."

    # Define the destination
    $destination = "$env:TEMP\\PowerShell-latest.msi"

    Invoke-WebRequest -Uri "$URL" -OutFile $destination

    Start-Process -FilePath msiexec.exe -ArgumentList "/i $destination /qn /norestart" -Wait -NoNewWindow

    Remove-Item $destination

    Write-Host "PowerShell Core Install - Done."
}