# Must be run from w/in Powershell (Core)
Install-Module Microsoft.WinGet.Client -Scope AllUsers -AcceptLicense -AllowClobber -Force
Import-Module Microsoft.WinGet.Client -Force -Global

function Write-Status {
    process {
        if ($_.Status -eq 'Ok') {
            Write-Output "`u{2713}"
        }
        else {
            Write-Output "$($_.Status) $($_.ExtendedErrorCode)"
        }
    }
}

function Install-PackageWithStatus {
    param (
        [Parameter(Mandatory = $true)]
        [string]$packageName,
        [Parameter(Mandatory = $true)]
        [string]$packageId
    )

    & $PSScriptRoot\Run-WithStatus.ps1 "Installing $packageName" { Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id $packageId | Write-Status }
}

Install-PackageWithStatus -packageId Microsoft.VisualStudioCode -packageName "VS Code"
Install-PackageWithStatus -packageId 7zip.7zip -packageName "7Zip"
Install-PackageWithStatus -packageId Docker.DockerDesktop -packageName "Docker Desktop"
Install-PackageWithStatus -packageId GoLang.Go -packageName "Go"
Install-PackageWithStatus -packageId 'Notepad++.Notepad++' -packageName "Notepad++"
Install-PackageWithStatus -packageId GnuPG.Gpg4win -packageName "GPG4Win"
Install-PackageWithStatus -packageId Microsoft.PowerToys -packageName "Windows Powertoys"
Install-PackageWithStatus -packageId Microsoft.Azure.StorageExplorer -packageName "Microsoft Azure Storage Explorer"
Install-PackageWithStatus -packageId Python.Launcher -packageName "Python 3"