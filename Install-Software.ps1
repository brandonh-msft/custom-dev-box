# Must be run from w/in Powershell (Core)
Write-Host "Installing software via PowerShell WinGet..."
Install-PackageProvider WinGet -Force -Scope AllUsers

Write-Host "Installing Powershell Core"
Install-Package -PackageManagementProvider WinGet Microsoft.PowerShell -Scope AllUsers -Force
Write-Host "Installing VS Code"
Install-Package -PackageManagementProvider WinGet -Scope AllUsers -Force -AcceptLicense -Force Microsoft.VisualStudioCode
Write-Host "Installing 7Zip"
Install-Package -PackageManagementProvider WinGet -Scope AllUsers -Force 7zip.7zip
Write-Host "Installing Docker Desktop"
Install-Package -PackageManagementProvider WinGet -Scope AllUsers -Force Docker.DockerDesktop 
Write-Host "Installing Go"
Install-Package -PackageManagementProvider WinGet -Scope AllUsers -Force GoLang.Go 
Write-Host "Installing Bicep"
Install-Package -PackageManagementProvider WinGet -Scope AllUsers -Force Microsoft.Bicep 
Write-Host "Installing Terraform"
Install-Package -PackageManagementProvider WinGet -Scope AllUsers -Force Hashicorp.Terraform 
Write-Host "Installing Notepad++"
Install-Package -PackageManagementProvider WinGet -Scope AllUsers -Force 'Notepad++.Notepad++' 
Write-Host "Installing GPG4Win"
Install-Package -PackageManagementProvider WinGet -Scope AllUsers -Force GnuPG.Gpg4win 
Write-Host "Installing Dev Home"
Install-Package -PackageManagementProvider WinGet -Scope AllUsers -Force Microsoft.DevHome 
Write-Host "Installing Windows Powertoys"
Install-Package -PackageManagementProvider WinGet -Scope AllUsers -Force Microsoft.PowerToys 
Write-Host "Installing Microsoft Azure Storage Explorer"
Install-Package -PackageManagementProvider WinGet -Scope AllUsers -Force Microsoft.Azure.StorageExplorer 
Write-Host "Installing Python 3"
Install-Package -PackageManagementProvider WinGet -Scope AllUsers -Force Python.Launcher 