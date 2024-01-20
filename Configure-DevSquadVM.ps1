param([String]$azureFilesKey)

./Set-TimezoneRedirection.ps1

./Set-WindowsOptimization -Optimizations 'WindowsMediaPlayer','ScheduledTasks','DefaultUserSettings','Autologgers','Services','NetworkOptimizations','LGPO','DiskCleanup','Edge','RemoveLegacyIE'

./Create-DevDrive.ps1

./Mount-AzureFiles.ps1 -account squadstorage -share software -key $azureFilesKey

./Install-Tools.ps1