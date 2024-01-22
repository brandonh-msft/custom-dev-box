param([String]$azureFilesKey)

Write-Host "Applying Timezone Redirecting settings"
& $PSScriptRoot\Set-TimezoneRedirection.ps1

# Write-Host "Applying Windows Optimizations"
# & $PSScriptRoot\Set-WindowsOptimization -Optimizations 'WindowsMediaPlayer','ScheduledTasks','DefaultUserSettings','Autologgers','Services','NetworkOptimizations','LGPO','DiskCleanup','Edge','RemoveLegacyIE'

Write-Host "Creating DevDrive"
& $PSScriptRoot\Create-DevDrive.ps1

Write-Host "Mounting Azure Files 'software' share"
& $PSScriptRoot\Mount-AzureFiles.ps1 -account squadstorage -share software -key $azureFilesKey

Write-Host "Installing tools"
& $PSScriptRoot\Install-Tools.ps1
