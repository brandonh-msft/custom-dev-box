param([string]$taskName)

. $PSScriptRoot\functions.ps1

Write-Output "Executing one-time user setup..."

& $PSScriptRoot\Install-UserSoftware.ps1

Write-Host "Unpinning Taskbar things"
UnpinFrom-Taskbar "Microsoft Store"

# Disable the scheduled task
$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskName }

if ($taskExists) {
    Disable-ScheduledTask -TaskName $taskName
    Write-Output "Task '$taskName' has been disabled."
}
else {
    Write-Output "Task '$taskName' does not exist."
}
