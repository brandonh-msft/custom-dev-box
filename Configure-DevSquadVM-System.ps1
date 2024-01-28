Write-Host "Applying Timezone Redirecting settings"
& $PSScriptRoot\Set-TimezoneRedirection.ps1

Write-Host "Applying Windows Optimizations"
& $PSScriptRoot\Set-WindowsOptimization -Optimizations 'WindowsMediaPlayer', 'ScheduledTasks', 'DefaultUserSettings', 'Autologgers', 'Services', 'NetworkOptimizations', 'LGPO', 'Edge', 'RemoveLegacyIE'

Write-Host "Creating DevDrive"
& $PSScriptRoot\Create-DevDrive.ps1 -DriveLetter 'E' # Because D is already taken by the DVD drive

Write-Host "Removing DVD drive from the system"
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\cdrom -Name Start -Value 4 -Type DWord