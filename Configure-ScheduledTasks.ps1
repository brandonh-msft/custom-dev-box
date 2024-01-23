Write-Host "Adding DevDrive Mount scheduled task"
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "Mount-Vhd c:\devdrive.vhdx"
$Trigger = New-ScheduledTaskTrigger -AtLogon
$Principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings
Register-ScheduledTask -TaskName "Mount DevDrive" -InputObject $Task

Write-Host "Adding S: mount scheduled task"
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "New-PSDrive -Name S -PSProvider FileSystem -Root `"\\squadstorage.file.core.windows.net\software`" -Persist"
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
Register-ScheduledTask -TaskName "Mount Squad Software storage" -InputObject $Task