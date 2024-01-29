$ErrorActionPreference = "Stop"

try {
    Write-Host "Checking for Winget..."

    winget -v

    Write-Host "Winget is installed."
}
catch {
    Write-Host "Winget is not installed."
}

Write-Host "Installing software via PowerShell WinGet..."
Install-Module -Name Microsoft.WinGet.Client
Import-Module -Name Microsoft.WinGet.Client

Write-Host "Installing Powershell Core"
Install-WinGetPackage -Id Microsoft.PowerShell -Scope System -Mode Silent -Force
Write-Host "Installing VS Code"
Install-WinGetPackage -Id Microsoft.VisualStudioCode -Scope System -Mode Silent -Force
Write-Host "Installing 7Zip"
Install-WinGetPackage 7zip.7zip -Scope System -Mode Silent -Force
Write-Host "Installing Docker Desktop"
Install-WinGetPackage Docker.DockerDesktop -Scope System -Mode Silent -Force
Write-Host "Installing Go"
Install-WinGetPackage GoLang.Go -Scope System -Mode Silent -Force
Write-Host "Installing Bicep"
Install-WinGetPackage Microsoft.Bicep -Scope System -Mode Silent -Force
Write-Host "Installing Terraform"
Install-WinGetPackage Hashicorp.Terraform -Scope System -Mode Silent -Force
Write-Host "Installing Notepad++"
Install-WinGetPackage --id 'Notepad++.Notepad++' -Scope System -Mode Silent -Force
Write-Host "Installing GPG4Win"
Install-WinGetPackage --id GnuPG.Gpg4win -Scope System -Mode Silent -Force
Write-Host "Installing Dev Home"
Install-WinGetPackage --id Microsoft.DevHome -Scope System -Mode Silent -Force
Write-Host "Installing Windows Powertoys"
Install-WinGetPackage --id Microsoft.PowerToys -Scope System -Mode Silent -Force
Write-Host "Installing Microsoft Azure Storage Explorer"
Install-WinGetPackage --id Microsoft.Azure.StorageExplorer -Scope System -Mode Silent -Force
Write-Host "Installing Python 3"
Install-WinGetPackage --id Python.Launcher -Scope System -Mode Silent -Force