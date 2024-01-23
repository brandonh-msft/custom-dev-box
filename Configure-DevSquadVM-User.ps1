Write-Host "Installing Postman"
choco install postman -y -f -r --no-progress --ignoredetectedreboot --pin

Write-Host "Removing pinned things"
& $PSScriptRoot\Unpin-App.ps1 "Microsoft Store"
