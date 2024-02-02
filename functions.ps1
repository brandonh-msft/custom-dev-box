function Write-Status
{
    process
    {
        if ($_.Status -eq 'Ok')
        {
            Write-Output "`u{2713}"
        }
        else
        {
            Write-Output "$($_.Status) $($_.ExtendedErrorCode)"
        }
    }
}

function Install-PackageWithStatus
{
    param (
        [Parameter(Mandatory = $true)]
        [string]$packageName,
        [Parameter(Mandatory = $true)]
        [string]$packageId
    )

    Start-WithStatus "Installing $packageName" { Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id $packageId | Write-Status }
}

function Start-WithStatus (
    [Parameter(Mandatory = $true)]
    [string]$status,
    [Parameter(Mandatory = $true)]
    [scriptblock]$scriptBlock
)
{
    Write-Host "$status..."
    & $scriptBlock
    Write-Host "$status - Done."
}