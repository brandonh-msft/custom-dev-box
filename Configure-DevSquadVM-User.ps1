Write-Host "Creating DevDrive"
& $PSScriptRoot\Create-DevDrive.ps1

Write-Host "Mounting Azure Files 'software' share"
& $PSScriptRoot\Mount-AzureFiles.ps1 -account squadstorage -share software -key $azureFilesKey

Write-Host "Installing Postman"
choco install postman -y -f -r --no-progress --ignoredetectedreboot --pin

Write-Host "Removing pinned things"
& $PSScriptRoot\Unpin-App.ps1 "Microsoft Store"
