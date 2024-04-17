. $PSScriptRoot\functions.ps1

$script = {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show('Your Dev Box is now completing setup. Do not close any Powershell/Terminal windows. Upon completion, it will reboot.', 'Continuing Setup...')
}

Start-Process pwsh -ArgumentList "-w Hidden -NoProfile -ExecutionPolicy Bypass -Command & {$script}"

Write-Output "Executing one-time user setup ($($env:USERNAME))..."

# Add the current user to docker-users
Add-LocalGroupMember -Group 'docker-users' -Member $env:USERNAME

Start-WithStatus "Installing Ubuntu on WSL" { wsl --install -d Ubuntu -n }

Install-PackageWithStatus -packageId 7zip.7zip -packageName "7Zip" -user
Install-PackageWithStatus -packageId Microsoft.DevHome -packageName "Dev Home" -cli -user
Install-PackageWithStatus -packageId 9MV8F79FGXTR -packageName "Dev Home Azure Extension" -user
Install-PackageWithStatus -packageId 9NZCC27PR6N6 -packageName "Dev Home GitHub Extension" -user
Install-PackageWithStatus -packageId Hashicorp.Terraform -packageName "Terraform" -user
Install-PackageWithStatus -packageId Postman.Postman -packageName "Postman" -user

Start-WithStatus "Updating WinGet packages" { $(Get-WinGetPackage | Where-Object { $_.IsUpdateAvailable -eq $true -and $_.Id -ne 'Microsoft.Office' }) | Update-WinGetPackage -Mode Silent }

Start-WithStatus "Cleaning up Taskbar" {

    UnpinFrom-Taskbar "Microsoft Store"

    # Start-WithStatus "Cleaning up desktop" { Remove-Item C:\Users\Public\Desktop\*.lnk }
    # Start-WithStatus "Cleaning up desktop" { Remove-Item "$($env:USERPROFILE)\Desktop\*.lnk" }

    & $PSScriptRoot\Customize-Taskbar.ps1 -RemoveSearch -RemoveTaskView -StartMorePins -RunForExistingUsers

    # Combine buttons when full
    $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-RegistryKeyValue -Path $registryPath -Name "TaskbarGlomLevel" -Value 1
}

Start-WithStatus "Configuring Start Menu" {
    # Open the registry
    $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

    # Don't show recently added apps
    Set-RegistryKeyValue -Path $registryPath -Name "Start_TrackProgs" -Value 0

    # Show most used apps
    Set-RegistryKeyValue -Path $registryPath -Name "Start_TrackDocs" -Value 1

    # Show recently opened items
    Set-RegistryKeyValue -Path $registryPath -Name "Start_ShowRecentDocs" -Value 1

    # Don't show recommendations
    Set-RegistryKeyValue -Path $registryPath -Name "Start_IrisRecommendations" -Value 0
}

Start-WithStatus "Configuring theme" {
    # Open the registry
    $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"

    # Enable Dark Mode for both Windows and apps
    Set-RegistryKeyValue -Path $registryPath -Name "AppsUseLightTheme" -Value 0
    Set-RegistryKeyValue -Path $registryPath -Name "SystemUsesLightTheme" -Value 0
    # Turn on Transparency Effects
    Set-RegistryKeyValue -Path $registryPath -Name "EnableTransparency" -Value 1
    # Show accent color on start & taskbar
    Set-RegistryKeyValue -Path $registryPath -Name "ColorPrevalence" -Value 2

    # Turn on Transparency Effects
    $registryPath = "HKCU:\Software\Microsoft\Windows\DWM"
    Set-RegistryKeyValue -Path $registryPath -Name "ForceEffectMode" -Value 2
    # Turn on the Accent color on title bars and window borders
    Set-RegistryKeyValue -Path $registryPath -Name "ColorPrevalence" -Value 1

    # Set the Accent Color to Automatic
    Set-RegistryKeyValue -Path "HKCU:\Control Panel\Desktop" -Name "AutoColorization" -Value 1
}

Start-WithStatus "Configuring Multitasking settings" {
    # Open the registry
    $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

    # Do not show tabs in Alt+Tab view
    Set-RegistryKeyValue -Path $registryPath -Name "MultiTaskingAltTabFilter" -Value 3

    # Enable window shake
    Set-RegistryKeyValue -Path $registryPath -Name "DisallowShaking" -Value 0
}

Start-WithStatus "Configuring other Windows Settings" {

    # Save state & restart apps after reboot
    Set-RegistryKeyValue -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "RestartApps" -Value 1

    # Turn off Developer Mode
    Set-RegistryKeyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 0

    # Show protected operating system files (Recommended)
    Set-RegistryKeyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Value 1

    # Turn on 'End Task' for Taskbar icons
    Set-RegistryKeyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" -Name "TaskbarEndTask" -Value 1

    # Show file extensions in Explorer
    Set-RegistryKeyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
}

# Reboot to ensure everything takes effect. We noticed this was necessary for Docker & WSL to work properly
shutdown /r /f /t 20