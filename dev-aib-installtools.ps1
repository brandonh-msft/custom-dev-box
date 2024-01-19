$ErrorActionPreference = "Stop"

Write-Host "Installing software via Chocolatey..."
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Host "Installing Notepad++"
choco install notepadplusplus -y
Write-Host "Installing Postman"
choco install postman -y
Write-Host "Installing VS Code"
choco install vscode -y
Write-Host "Installing Azure CLI"
choco install azure-cli -y
Write-Host "Installing GPG4Win"
choco install gpg4win -y
Write-Host "Installing 7Zip"
choco install 7zip -y
Write-Host "Installing GitHub CLI"
choco install github-cli -y
Write-Host "Installing Powershell Core"
choco install powershell-core -y
Write-Host "Installing Git Credential Manager"
choco install git-credential-manager -y
Write-Host "Installing Docker Desktop"
choco install docker-desktop -y
Write-Host "Installing Windows Powertoys"
choco install powertoys -y
Write-Host "Installing Microsoft Azure Storage Explorer"
choco install microsoftazurestorageexplorer -y
Write-Host "Installing Python 3"
choco install python3 -y
Write-Host "Installing Go"
choco install golang -y
Write-Host "Installing Terraform"
choco install terraform -y
Write-Host "Installing Bicep"
choco install bicep -y