param([string]$taskName)

# DevDrive is created on E: due to D: being taken by the DVD drive during initial imaging. Mount and re-assign to D:
Mount-Vhd c:\devdrive.vhdx
& $PSScriptRoot\Update-DriveLetter.ps1 'E:' 'D:'

# Install Postman
Install-WinGetPackage Postman.Postman -Mode Silent -Force

# Install Ubuntu distro on wsl
wsl --install -d Ubuntu -n

# Update Winget packages at the user-level
Install-WinGetPackage 9MV8F79FGXTR -Mode Silent -Force # Dev Home Azure Extension
Install-WinGetPackage 9NZCC27PR6N6 -Mode Silent -Force # Dev Home GitHub Extension
Update-WinGetPackage -Mode Silent -Force

# Disable the scheduled task
$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskName }

if ($taskExists) {
    Disable-ScheduledTask -TaskName $taskName
    Write-Output "Task '$taskName' has been disabled."
}
else {
    Write-Output "Task '$taskName' does not exist."
}
