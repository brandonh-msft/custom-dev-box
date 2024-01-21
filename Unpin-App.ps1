param([string]$appname)
try {
    ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ? {$_.Name -eq $appname}).Verbs() | ? {$_.Name.replace('&','') -match 'Unpin from Taskbar'} | % {$_.DoIt()}
    return "App '$appname' unpinned from Taskbar"
} catch {
    Write-Error "Error Unpinning App!"
}