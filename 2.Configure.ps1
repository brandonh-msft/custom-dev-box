param([String]$azureFilesKey)

Write-Host "Updating Windows Store apps..."
& $PSScriptRoot\Update-StoreApps.ps1

pwsh -MTA -noni -nop -ex Unrestricted -File c:\scripts\Install-Software.ps1

Write-Host "Changing DevDrive drive letter..."
Mount-VHD c:\devdrive.vhdx
& $PSScriptRoot\Update-DriveLetter.ps1 'E:' 'D:'

Write-Host "Adding One Time Setup scheduled task..."
$Action = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument "$PSScriptRoot\Apply-OneTimeUserSetup.ps1 -taskName 'One Time Setup'"
$Trigger = New-ScheduledTaskTrigger -AtLogon
$Principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -Hidden -MultipleInstances IgnoreNew 
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings
Register-ScheduledTask -TaskName "One Time Setup" -InputObject $Task

Write-Host "Adding S: mount scheduled task..."
$Action = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument "$PSScriptRoot\Mount-AzureFiles.ps1 -key $azureFilesKey"
$Principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users"
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -Hidden -MultipleInstances IgnoreNew -RunOnlyIfNetworkAvailable
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings
Register-ScheduledTask -TaskName "Mount Squad Software storage" -InputObject $Task

Write-Host "Cleaning up desktop..."
rm -Force C:\Users\Public\Desktop\*.lnk

DISM.exe /Online /Set-ReservedStorageState /State:Disabled
