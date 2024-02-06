. $PSScriptRoot\functions.ps1

Write-Output "Executing one-time user setup..."

Start-WithStatus "Installing Ubuntu on WSL" { wsl --install -d Ubuntu -n }

Install-PackageWithStatus -packageId 7zip.7zip -packageName "7Zip"
Install-PackageWithStatus -packageId Microsoft.DevHome -packageName "Dev Home" -cli -user
Install-PackageWithStatus -packageId 9MV8F79FGXTR -packageName "Dev Home Azure Extension" -user
Install-PackageWithStatus -packageId 9NZCC27PR6N6 -packageName "Dev Home GitHub Extension" -user
Install-PackageWithStatus -packageId Hashicorp.Terraform -packageName "Terraform" -user
Install-PackageWithStatus -packageId Postman.Postman -packageName "Postman" -user

Start-WithStatus "Updating WinGet packages" { $(Get-WinGetPackage | Where-Object { $_.IsUpdateAvailable -eq $true -and $_.Name -ne 'Microsoft 365 Apps for enterprise' }) | Update-WinGetPackage -Mode Silent -Force }

Start-WithStatus "Cleaning up Taskbar..." {
    UnpinFrom-Taskbar "Microsoft Store"

    # Start-WithStatus "Cleaning up desktop" { Remove-Item -Force C:\Users\Public\Desktop\*.lnk }
    # Start-WithStatus "Cleaning up desktop" { Remove-Item -Force "$($env:USERPROFILE)\Desktop\*.lnk" }

    & $PSScriptRoot\Customize-Taskbar.ps1 -RemoveTaskView -RemoveChat -StartMorePins
}