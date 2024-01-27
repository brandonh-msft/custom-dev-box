param([string]$taskName)

# DevDrive is created on E: due to D: being taken by the DVD drive during initial imaging. Mount and re-assign to D:
Mount-Vhd c:\devdrive.vhdx
& $PSScriptRoot\Update-DriveLetter.ps1 'E:' 'D:'

# Install Postman
winget install --id Postman.Postman --silent --force

# Install Ubuntu distro on wsl
wsl --install -d Ubuntu -n

# Update Winget packages at the user-level
winget install --id 9MV8F79FGXTR --silent --force # Dev Home Azure Extension
winget install --id 9NZCC27PR6N6 --silent --force # Dev Home GitHub Extension
winget upgrade --all -h

# Disable the scheduled task
$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskName }

if ($taskExists) {
    Disable-ScheduledTask -TaskName $taskName
    Write-Output "Task '$taskName' has been disabled."
}
else {
    Write-Output "Task '$taskName' does not exist."
}
