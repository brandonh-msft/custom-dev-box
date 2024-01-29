$ErrorActionPreference = "Stop"

try {
    Write-Host "Checking for Winget..."

    winget -v

    Write-Host "Winget is installed."
}
catch {
    Write-Host "Winget is not installed."
}

try {
    Write-Host "Checking for PowerShell Core..."

    pwsh -v

    Write-Host "PowerShell Core is installed."
}
catch {
    Write-Host "PowerShell Core is not installed. Installing ..."

    # Get the latest download URL
    $URL = Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
    $URL = $URL.assets.browser_download_url -match 'win-x64.msi'

    # Define the destination
    $destination = "$env:TEMP\\PowerShell-latest.msi"

    Invoke-WebRequest -Uri $URL -OutFile $destination

    Start-Process -FilePath msiexec.exe -ArgumentList "/i $destination /qn /norestart" -Wait -NoNewWindow

    Remove-Item $destination
}