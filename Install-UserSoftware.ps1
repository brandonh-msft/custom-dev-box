. $PSScriptRoot\functions.ps1

Install-PackageWithStatus -packageId Postman.Postman -packageName "Postman"
Install-PackageWithStatus -packageId Microsoft.DevHome -packageName "Dev Home"
Install-PackageWithStatus -packageId 9MV8F79FGXTR -packageName "Dev Home Azure Extension"
Install-PackageWithStatus -packageId 9NZCC27PR6N6 -packageName "Dev Home GitHub Extension"
Install-PackageWithStatus -packageId Microsoft.Bicep -packageName "Bicep"
Install-PackageWithStatus -packageId Hashicorp.Terraform -packageName "Terraform"

Start-WithStatus "Updating WinGet packages" { $(Get-WinGetPackage | Where-Object { $_.IsUpdateAvailable -eq $true -and $_.Name -ne 'Microsoft 365 Apps for enterprise' }) | Update-WinGetPackage -Mode Silent -Force }