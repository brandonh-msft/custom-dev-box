param([string]$taskName)

. $PSScriptRoot\functions.ps1

& $PSScriptRoot\Install-UserSoftware.ps1

Write-Host "Unpinning Taskbar things"
UnpinFrom-Taskbar "Microsoft Store"

& $PSScriptRoot\Customize-Taskbar.ps1 -RemoveTaskView -RemoveChat -StartMorePins

Write-Host "Pinning apps to Start"
PinTo-Start "Microsoft Visual Studio"
PinTo-Start "Visual Studio Code"
PinTo-Start "Postman"
PinTo-Start "Dev Home (Preview)"
PinTo-Start "Docker"

# Disable the scheduled task
$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskName }

if ($taskExists) {
    Disable-ScheduledTask -TaskName $taskName
    Write-Output "Task '$taskName' has been disabled."
}
else {
    Write-Output "Task '$taskName' does not exist."
}
