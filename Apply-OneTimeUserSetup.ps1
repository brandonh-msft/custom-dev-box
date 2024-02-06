param([string]$elevatedTaskName, [string]$unelevatedTaskName)

. $PSScriptRoot\functions.ps1

Write-Output "Executing elevated one-time user setup..."

# Install Ubuntu distro on wsl
wsl --install -d Ubuntu -n

Install-PackageWithStatus -packageId 7zip.7zip -packageName "7Zip"
Install-PackageWithStatus -packageId Microsoft.DevHome -packageName "Dev Home" -cli -user
Install-PackageWithStatus -packageId 9MV8F79FGXTR -packageName "Dev Home Azure Extension" -user
Install-PackageWithStatus -packageId 9NZCC27PR6N6 -packageName "Dev Home GitHub Extension" -user
Install-PackageWithStatus -packageId Hashicorp.Terraform -packageName "Terraform" -user

Start-WithStatus "Updating WinGet packages" { $(Get-WinGetPackage | Where-Object { $_.IsUpdateAvailable -eq $true -and $_.Name -ne 'Microsoft 365 Apps for enterprise' }) | Update-WinGetPackage -Mode Silent -Force }

Install-PackageWithStatus -packageId Postman.Postman -packageName "Postman" -user

Write-Host "Unpinning Taskbar things"
UnpinFrom-Taskbar "Microsoft Store"

# Start-WithStatus "Cleaning up desktop" { Remove-Item -Force C:\Users\Public\Desktop\*.lnk }
# Start-WithStatus "Cleaning up desktop" { Remove-Item -Force "$($env:USERPROFILE)\Desktop\*.lnk" }

& $PSScriptRoot\Customize-Taskbar.ps1 -RemoveTaskView -RemoveChat -StartMorePins

# Disable the elevated scheduled task
$taskExists = Get-ScheduledTask -TaskName $elevatedTaskName

if ($taskExists)
{
    Disable-ScheduledTask -TaskName $taskName
    Write-Output "Task '$taskName' has been disabled."
}
else
{
    Write-Output "Task '$taskName' does not exist."
}

# Disable the user-level scheduled task (user level task can't do this on its own as elevation is required)
$taskExists = Get-ScheduledTask -TaskName $unelevatedTaskName

if ($taskExists)
{
    Disable-ScheduledTask -TaskName $taskName
    Write-Output "Task '$taskName' has been disabled."
}
else
{
    Write-Output "Task '$taskName' does not exist."
}
