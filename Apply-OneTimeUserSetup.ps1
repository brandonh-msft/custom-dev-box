. $PSScriptRoot\functions.ps1

Write-Output "Executing one-time user setup..."

Install-PackageWithStatus -packageId Postman.Postman -packageName "Postman" -user

Write-Host "Unpinning Taskbar things"
UnpinFrom-Taskbar "Microsoft Store"