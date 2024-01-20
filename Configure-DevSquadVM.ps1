param([String]$azureFilesKey)

Write-Host "Applying Timezone Redirecting settings"
./Set-TimezoneRedirection.ps1

Write-Host "Applying Windows Optimizations"
./Set-WindowsOptimization -Optimizations 'WindowsMediaPlayer','ScheduledTasks','DefaultUserSettings','Autologgers','Services','NetworkOptimizations','LGPO','DiskCleanup','Edge','RemoveLegacyIE'

Write-Host "Creating DevDrive"
./Create-DevDrive.ps1

Write-Host "Mounting Azure Files 'software' share"
./Mount-AzureFiles.ps1 -account squadstorage -share software -key $azureFilesKey

Write-Host "Installing tools"
./Install-Tools.ps1

Write-Host "Removing things"
./Remove-Things.ps1