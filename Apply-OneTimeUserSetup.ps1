param([string]$taskName)

# DevDrive is created on E: due to D: being taken by the DVD drive during initial imaging. Mount and re-assign to D:
$v = Mount-VHD c:\devdrive.vhdx -Passthru | Get-Disk | Get-Partition | Get-Volume
Write-Output $v
if ($v.DriveLetter -ne 'D') {
    & $PSScriptRoot\Run-WithStatus.ps1 "Changing DevDrive drive letter" { & $PSScriptRoot\Update-DriveLetter.ps1 "$($v.DriveLetter):" 'D:' }
}

# Install Ubuntu distro on wsl
wsl --install -d Ubuntu -n

& $PSScriptRoot\Install-UserSoftware.ps1

# Disable the scheduled task
$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskName }

if ($taskExists) {
    Disable-ScheduledTask -TaskName $taskName
    Write-Output "Task '$taskName' has been disabled."
}
else {
    Write-Output "Task '$taskName' does not exist."
}
