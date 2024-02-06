param([String]$azureFilesKey, [string]$account = "squadstorage", [string]$share = "software")

. $PSScriptRoot\functions.ps1

Start-WithStatus "Installing system-level software packages" { pwsh -MTA -noni -nop -ex Unrestricted -File c:\scripts\Install-SystemSoftware.ps1 }
Start-WithStatus "Adding One-Time DevSquad Dev Box Setup to RunOnce" {
    Set-RegistryKeyValue -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\RunOnce" -Name "One-Time DevSquad Dev Box Setup" -Value "pwsh -MTA -noni -nop -ex Unrestricted -File c:\\scripts\\Apply-OneTimeUserSetup.ps1"
}

$Trigger = New-ScheduledTaskTrigger -AtLogon
Start-WithStatus "Adding S: mount scheduled task" { 
    $Action = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument "$PSScriptRoot\Mount-AzureFiles.ps1 -key $azureFilesKey -account $account -share $share"
    $Principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users"
    $Settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -MultipleInstances IgnoreNew -RunOnlyIfNetworkAvailable -Hidden
    $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings
    Register-ScheduledTask -TaskName "Mount Squad Software storage" -InputObject $Task
}

Start-WithStatus "Adding DevDrive mount scheduled task" { 
    $Action = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument "-c `"Mount-VHD -Path c:\devdrive.vhdx`""
    $Principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users" -RunLevel Highest
    $Settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -MultipleInstances IgnoreNew -Hidden
    $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings
    Register-ScheduledTask -TaskName "Mount Dev Drive" -InputObject $Task
}

# Start-WithStatus "Removing DVD drive from the system" { Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\cdrom -Name Start -Value 4 -Type DWord }
Start-WithStatus "Disabling Reserved Storage" { DISM.exe /Online /Set-ReservedStorageState /State:Disabled }
