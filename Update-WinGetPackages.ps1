Install-Module Microsoft.WinGet.Client -AcceptLicense -Force

$pwshOutput = (pwsh -MTA -c "Get-WingetPackage | Where-Object IsUpdateAvailable -eq $true | Where-Object Id -ne 'Microsoft.Office' | ConvertTo-Json")
$appsToUpdate = ($pwshOutput | ConvertFrom-Json) | Where-Object IsUpdateAvailable -eq $true | Select-Object -ExpandProperty Id
pwsh -MTA -cwa '$args | % { Write-Output \"Updating $_ ...\" ; Update-WingetPackage -Id $_ -Mode Silent -Force -MatchOption EqualsCaseInsensitive }' $appsToUpdate