param([String]$azureFilesKey)

Write-Host "Adding One Time Setup scheduled task"
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "c:\scripts\Apply-OneTimeSetup.ps1"
$Trigger = New-ScheduledTaskTrigger -AtLogon
$Principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -Hidden -MultipleInstances IgnoreNew 
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings
Register-ScheduledTask -TaskName "One Time Setup" -InputObject $Task

Write-Host "Adding S: mount scheduled task"
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "c:\scripts\Mount-AzureFiles.ps1 -key $azureFilesKey"
$Principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users"
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -Hidden -MultipleInstances IgnoreNew -RunOnlyIfNetworkAvailable
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings
Register-ScheduledTask -TaskName "Mount Squad Software storage" -InputObject $Task