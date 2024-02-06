. $PSScriptRoot\functions.ps1

# Must be run from w/in Powershell (Core)
Install-Module Microsoft.WinGet.Client -Scope AllUsers -AcceptLicense -AllowClobber -Force
Import-Module Microsoft.WinGet.Client -Force -Global

Install-PackageWithStatus -packageId Microsoft.VisualStudioCode -packageName "VS Code"
Install-PackageWithStatus -packageId Docker.DockerDesktop -packageName "Docker Desktop"
Install-PackageWithStatus -packageId GoLang.Go -packageName "Go"
Install-PackageWithStatus -packageId 'Notepad++.Notepad++' -packageName "Notepad++"
Install-PackageWithStatus -packageId GnuPG.Gpg4win -packageName "GPG4Win"
Install-PackageWithStatus -packageId Microsoft.PowerToys -packageName "Windows Powertoys"
Install-PackageWithStatus -packageId Microsoft.Azure.StorageExplorer -packageName "Microsoft Azure Storage Explorer"
Install-PackageWithStatus -packageId Python.Launcher -packageName "Python 3"