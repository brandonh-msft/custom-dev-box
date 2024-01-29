param (
    [Parameter(Mandatory=$true)]
    [string]$status,
    [Parameter(Mandatory=$true)]
    [scriptblock]$scriptBlock
)

Write-Host "$status..."
& $scriptBlock
Write-Host "$status - Done."
