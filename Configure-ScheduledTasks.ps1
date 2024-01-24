param([String]$azureFilesKey)

Write-Host "Adding DevDrive Mount scheduled task"
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "Mount-Vhd c:\devdrive.vhdx"
$Trigger = New-ScheduledTaskTrigger -AtLogon
$Principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -Hidden -MultipleInstances IgnoreNew 
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings
Register-ScheduledTask -TaskName "Mount DevDrive" -InputObject $Task

Write-Host "Adding S: mount scheduled task"
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "c:\scripts\Mount-AzureFiles.ps1 -key $azureFilesKey"
$Principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users"
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -Hidden -MultipleInstances IgnoreNew -RunOnlyIfNetworkAvailable
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings
Register-ScheduledTask -TaskName "Mount Squad Software storage" -InputObject $Task