$ErrorActionPreference = "Stop"

try {
    Write-Host "Checking for Winget..."

    winget list
}
catch {
    Write-Host "Winget is not installed. Installing..."

    # Get the download URL of the latest winget installer from GitHub:
    $API_URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    $DOWNLOAD_URL = $(Invoke-RestMethod $API_URL).assets.browser_download_url |
    Where-Object { $_.EndsWith(".msixbundle") }

    # Download the installer:
    Invoke-WebRequest -URI $DOWNLOAD_URL -OutFile winget.msixbundle -UseBasicParsing

    # Install winget:
    Add-AppxPackage winget.msixbundle

    # Remove the installer:
    Remove-Item winget.msixbundle
}

Write-Host "Installing software via winget..."

Write-Host "Installing Powershell Core"
winget install Microsoft.PowerShell --silent --force --scope machine
Write-Host "Installing VS Code"
winget install Microsoft.VisualStudioCode --silent --force --scope machine
Write-Host "Installing 7Zip"
winget install 7zip.7zip --silent --force --scope machine
Write-Host "Installing Docker Desktop"
winget install Docker.DockerDesktop --silent --force --scope machine
Write-Host "Installing Go"
winget install GoLang.Go --silent --force --scope machine
Write-Host "Installing Bicep"
winget install Microsoft.Bicep --silent --force --scope machine
Write-Host "Installing Terraform"
winget install Hashicorp.Terraform --silent --force --scope machine
Write-Host "Installing Notepad++"
winget install --id NotepadPlusPlus_7njy0v32s6xk6 --silent --force --scope machine
Write-Host "Installing GPG4Win"
winget install --id GnuPG.Gpg4win --silent --force --scope machine
Write-Host "Installing Dev Home"
winget install --id Microsoft.DevHome --silent --force --scope machine
Write-Host "Installing Windows Powertoys"
winget install --id Microsoft.PowerToys --silent --force --scope machine
Write-Host "Installing Microsoft Azure Storage Explorer"
winget install --id Microsoft.Azure.StorageExplorer --silent --force --scope machine
Write-Host "Installing Python 3"
winget install --id Python.Launcher --silent --force --scope machine