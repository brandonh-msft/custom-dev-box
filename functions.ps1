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

function Install-PackageWithStatus (
    [Parameter(Mandatory = $true)]
    [string]$packageName,
    [Parameter(Mandatory = $true)]
    [string]$packageId,
    [switch]$user
)
{
    if ($user)
    {
        Start-WithStatus "Installing $packageName" { Install-WinGetPackage -Scope UserOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id $packageId | Write-Status }
    }
    else
    {
        Start-WithStatus "Installing $packageName" { Install-WinGetPackage -Scope SystemOrUnknown -Mode Silent -MatchOption EqualsCaseInsensitive -Force -Id $packageId | Write-Status }
    }
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

function UnpinFrom-Taskbar ([string]$appname)
{
    try
    {
    ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ? { $_.Name -eq $appname }).Verbs() | ? { $_.Name.replace('&', '') -match 'Unpin from Taskbar' } | % { $_.DoIt() }
        return "App '$appname' unpinned from Taskbar"
    }
    catch
    {
        Write-Error "Error Unpinning '$appname'"
    }
}

function PinTo-Start (
    [Parameter (Mandatory = $true)]
    [string]$appname,
    [switch]$unpin
)
{
    try
    {
        if ($unpin.IsPresent)
        {
        ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ? { $_.Name -eq $appname }).Verbs() | ? { $_.Name.replace('&', '') -match 'From "Start" UnPin|Unpin from Start' } | % { $_.DoIt() }
            return "App '$appname' unpinned from Start"
        }
        else
        {
        ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ? { $_.Name -eq $appname }).Verbs() | ? { $_.Name.replace('&', '') -match 'To "Start" Pin|Pin to Start' } | % { $_.DoIt() }
            return "App '$appname' pinned to Start"
        }
    }
    catch
    {
        Write-Error "Error Pinning/Unpinning App '$appname' (App-Name correct?)"
    }
}
  