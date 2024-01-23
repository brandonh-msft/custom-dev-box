param([String]$azureFilesKey)

Write-Host "Applying Timezone Redirecting settings"
& $PSScriptRoot\Set-TimezoneRedirection.ps1

Write-Host "Applying Windows Optimizations"
& $PSScriptRoot\Set-WindowsOptimization -Optimizations 'WindowsMediaPlayer','ScheduledTasks','DefaultUserSettings','Autologgers','Services','NetworkOptimizations','LGPO','Edge','RemoveLegacyIE'

Write-Host "Installing tools"
& $PSScriptRoot\Install-Tools.ps1

# # Per https://github.com/hashicorp/packer/issues/4567
# Write-Host "Applying WinRM Fixes"
# & $PSScriptRoot\Fix-WinRM.ps1

Write-Host "Creating DevDrive"
& $PSScriptRoot\Create-DevDrive.ps1

Write-Host "Configuring Scheduled Tasks"
& $PSScriptRoot\Configure-ScheduledTasks.ps1