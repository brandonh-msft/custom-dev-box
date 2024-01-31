param([string]$taskName)

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
