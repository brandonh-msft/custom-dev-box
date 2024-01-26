$ErrorActionPreference = "Stop"

Write-Host "Installing software via Chocolatey..."
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Host "Installing VS Code"
choco install vscode -y -f -r --no-progress --ignoredetectedreboot 
Write-Host "Installing 7Zip"
choco install 7zip -y -f -r --no-progress --ignoredetectedreboot 
Write-Host "Installing Powershell Core"
choco install powershell-core -y -f -r --no-progress --ignoredetectedreboot
Write-Host "Installing Git Credential Manager"
choco install git-credential-manager-for-windows -y -f -r --no-progress --ignoredetectedreboot
Write-Host "Installing Docker Desktop"
choco install docker-desktop -y -f -r --no-progress --ignoredetectedreboot 
Write-Host "Installing Go"
choco install golang -y -f -r --no-progress --ignoredetectedreboot
Write-Host "Installing Terraform"
choco install terraform -y -f -r --no-progress --ignoredetectedreboot
Write-Host "Installing Bicep"
choco install bicep -y -f -r --no-progress --ignoredetectedreboot

Write-Host "Installing software via WinGet..."
Install-Module Microsoft.WinGet.Client -AcceptLicense -Force

Write-Host "Installing Notepad++"
pwsh -MTA -c "Install-WingetPackage -Id 'NotepadPlusPlus_7njy0v32s6xk6' -Mode Silent -Force -MatchOption EqualsCaseInsensitive -Scope System"
# choco install notepadplusplus -y -f -r --no-progress --ignoredetectedreboot 
Write-Host "Installing GPG4Win"
pwsh -MTA -c "Install-WingetPackage -Id 'GnuPG.Gpg4win' -Mode Silent -Force -MatchOption EqualsCaseInsensitive -Scope System"
# choco install gpg4win -y -f -r --no-progress --ignoredetectedreboot 
Write-Host "Installing Dev Home"
pwsh -MTA -c "Install-WingetPackage -Id 'Microsoft.DevHome' -Mode Silent -Force -MatchOption EqualsCaseInsensitive -Scope System"
pwsh -MTA -c "Install-WingetPackage -Id 'Microsoft.Windows.DevHomeAzureExtension_8wekyb3d8bbwe' -Mode Silent -Force -MatchOption EqualsCaseInsensitive -Scope System"
pwsh -MTA -c "Install-WingetPackage -Id 'Microsoft.Windows.DevHomeGitHubExtension_8wekyb3d8bbwe' -Mode Silent -Force -MatchOption EqualsCaseInsensitive -Scope System"
Write-Host "Installing Windows Powertoys"
pwsh -MTA -c "Install-WingetPackage -Id 'Microsoft.PowerToys' -Mode Silent -Force -MatchOption EqualsCaseInsensitive -Scope System"
# choco install powertoys -y -f -r --no-progress --ignoredetectedreboot 
Write-Host "Installing Microsoft Azure Storage Explorer"
pwsh -MTA -c "Install-WingetPackage -Id 'Microsoft.Azure.StorageExplorer' -Mode Silent -Force -MatchOption EqualsCaseInsensitive -Scope System"
# choco install microsoftazurestorageexplorer -y -f -r --no-progress --ignoredetectedreboot 
Write-Host "Installing Python 3"
pwsh -MTA -c "Install-WingetPackage -Id 'Python.Launcher' -Mode Silent -Force -MatchOption EqualsCaseInsensitive -Scope System"
# pwsh -MTA -c "Install-WingetPackage -Id 'Python.Python.3.11' -Mode Silent -Force -MatchOption EqualsCaseInsensitive -Scope System"
# choco install python3 -y -f -r --no-progress --ignoredetectedreboot