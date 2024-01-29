function Write-Status {
    process {
        if ($_.Status -eq 'Ok') {
            Write-Output "✅"
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

    & $PSScriptRoot\Run-WithStatus.ps1 "Installing $packageName" { Install-WinGetPackage -Scope Any -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id $packageId | Write-Status }
}

Install-PackageWithStatus -packageId Postman.Postman -packageName "Postman"
Install-PackageWithStatus -packageId 9MV8F79FGXTR -packageName "Dev Home Azure Extension"
Install-PackageWithStatus -packageId 9NZCC27PR6N6 -packageName "Dev Home GitHub Extension"
Install-PackageWithStatus -packageId Microsoft.Bicep -packageName "Bicep"
Install-PackageWithStatus -packageId Hashicorp.Terraform -packageName "Terraform"
Install-PackageWithStatus -packageId Microsoft.DevHome -packageName "Dev Home"

& $PSScriptRoot\Run-WithStatus.ps1 "Updating WinGet packages" { Update-WinGetPackage -Mode Silent -Force }