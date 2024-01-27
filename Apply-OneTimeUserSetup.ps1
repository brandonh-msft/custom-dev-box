param([string]$taskName)

# DevDrive is created on E: due to D: being taken by the DVD drive during initial imaging. Mount and re-assign to D:
Mount-Vhd c:\devdrive.vhdx
c:\scripts\Update-DriveLetter.ps1 'E:' 'D:'

# Install Postman
choco install postman -y -f -r --no-progress --ignoredetectedreboot

# Install Git Credential Manager for Windows
choco install git-credential-manager-for-windows -y -f -r --no-progress --ignoredetectedreboot

# Update Winget packages at the user-level
c:\scripts\Update-WinGetPackages.ps1

# Install Ubuntu distro on wsl
wsl --install -d Ubuntu -n

# Disable the scheduled task
$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskName }

if ($taskExists) {
    Disable-ScheduledTask -TaskName $taskName
    Write-Output "Task '$taskName' has been disabled."
}
else {
    Write-Output "Task '$taskName' does not exist."
}
