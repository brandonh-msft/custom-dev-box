# Must be run from w/in Powershell (Core)
Write-Host "Installing software via PowerShell WinGet..."
Install-Module Microsoft.WinGet.Client -Scope AllUsers -AcceptLicense -AllowClobber -Force
Import-Module Microsoft.WinGet.Client -Force -Global

function Write-Status {
    process {
        if ($_.Status -eq 'Ok') {
            Write-Output "✅"
        } else {
            Write-Output "$($_.Status) $($_.ExtendedErrorCode)"
        }
    }
}

Write-Host "Installing VS Code"
Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id Microsoft.VisualStudioCode | Write-Status
Write-Host "Installing 7Zip"
Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id 7zip.7zip | Write-Status
Write-Host "Installing Docker Desktop"
Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id Docker.DockerDesktop | Write-Status
Write-Host "Installing Go"
Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id GoLang.Go | Write-Status
Write-Host "Installing Bicep"
Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id Microsoft.Bicep | Write-Status
Write-Host "Installing Terraform"
Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id Hashicorp.Terraform | Write-Status
Write-Host "Installing Notepad++"
Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id 'Notepad++.Notepad++' | Write-Status
Write-Host "Installing GPG4Win"
Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id GnuPG.Gpg4win | Write-Status
Write-Host "Installing Dev Home"
Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id Microsoft.DevHome | Write-Status
Write-Host "Installing Windows Powertoys"
Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id Microsoft.PowerToys | Write-Status
Write-Host "Installing Microsoft Azure Storage Explorer"
Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id Microsoft.Azure.StorageExplorer | Write-Status
Write-Host "Installing Python 3"
Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id Python.Launcher | Write-Status