$ErrorActionPreference = "Stop"

Write-Host "Installing software via Chocolatey..."
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Host "Installing Notepad++"
choco install notepadplusplus -y -f -r --no-progress --ignoredetectedreboot --pin
Write-Host "Installing Postman"
choco install postman -y -f -r --no-progress --ignoredetectedreboot --pin
Write-Host "Installing VS Code"
choco install vscode -y -f -r --no-progress --ignoredetectedreboot --pin
Write-Host "Installing Azure CLI"
choco install azure-cli -y -f -r --no-progress --ignoredetectedreboot
Write-Host "Installing GPG4Win"
choco install gpg4win -y -f -r --no-progress --ignoredetectedreboot --pin
Write-Host "Installing 7Zip"
choco install 7zip -y -f -r --no-progress --ignoredetectedreboot --pin
Write-Host "Installing GitHub CLI"
choco install gh -y -f -r --no-progress --ignoredetectedreboot
Write-Host "Installing Powershell Core"
choco install powershell-core -y -f -r --no-progress --ignoredetectedreboot
Write-Host "Installing Git Credential Manager"
choco install git-credential-manager-for-windows -y -f -r --no-progress --ignoredetectedreboot
Write-Host "Installing Docker Desktop"
choco install docker-desktop -y -f -r --no-progress --ignoredetectedreboot --pin
Write-Host "Installing Windows Powertoys"
choco install powertoys -y -f -r --no-progress --ignoredetectedreboot --pin
Write-Host "Installing Microsoft Azure Storage Explorer"
choco install microsoftazurestorageexplorer -y -f -r --no-progress --ignoredetectedreboot --pin
Write-Host "Installing Python 3"
choco install python3 -y -f -r --no-progress --ignoredetectedreboot
Write-Host "Installing Go"
choco install golang -y -f -r --no-progress --ignoredetectedreboot
Write-Host "Installing Terraform"
choco install terraform -y -f -r --no-progress --ignoredetectedreboot
Write-Host "Installing Bicep"
choco install bicep -y -f -r --no-progress --ignoredetectedreboot
# Write-Host "Installing Office"
# choco install office365business -y
# Write-Host "Installing Teams"
# choco install Microsoft-teams -y