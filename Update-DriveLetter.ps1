param (
    [Parameter(Mandatory=$true)]
    [string]$Current,

    [Parameter(Mandatory=$true)]
    [string]$New
)

# Validate the input format
if (-not ($currentDriveLetter -match '^[A-Z]:$') -or -not ($newDriveLetter -match '^[A-Z]:$')) {
    Write-Output "Invalid input format. Please enter the drive letter in the format '<character>:'"
    return
}

# Check if the current drive letter exists
$currentDrive = Get-WmiObject -Class Win32_volume -Filter "DriveLetter = '$Current'"
if ($null -eq $currentDrive) {
    Write-Error "The current drive letter does not exist."
    return
}

# Check if the new drive letter does not exist
$newDrive = Get-WmiObject -Class Win32_volume -Filter "DriveLetter = '$New'"
if ($null -ne $newDrive) {
    Write-Error "The new drive letter already exists."
    return
}

# Change the drive letter
$currentDrive | Set-WmiInstance -Arguments @{DriveLetter="$New"}
Write-Output "Drive letter has been changed from $Current to $New."
