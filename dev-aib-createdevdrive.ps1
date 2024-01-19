<#
.SYNOPSIS
Creates a dev drive for usage with Azure Image Builder

.DESCRIPTION
Creates a new dev drive and mounts it then sets up the various package folders and environment variables.

.EXAMPLE
.\dev-aib-createdevdrive.ps1 -Path c:\newdevdrive.vhdx -DriveLetter X
#>

# Parameter help description
param(
[Parameter(HelpMessage="Path to the VHD file to create")]
[ValidateScript({
    if ([string]::IsNullOrEmpty($_.Trim()))
    {
        throw "Path cannot be empty."
    } else {
        $true
    }
})][string] $Path="c:\devdrive.vhdx", # Path to the VHD file to create
[Parameter(HelpMessage="Drive letter to mount the new VHD to")]
[ValidateScript({
    if ([string]::IsNullOrEmpty($_.Trim()))
    {
        throw "DriveLetter cannot be empty."
    } else {
        $true
    }
})][string] $DriveLetter="E" # Drive letter to mount the new VHD to
)

$ErrorActionPreference = "Stop"

Write-Host "Creating new VHD at $Path"
New-VHD -Path $Path -SizeBytes 100GB -Dynamic -ErrorAction Stop
Write-Host "VHD created, mounting..."
$diskImage = Mount-DiskImage -ImagePath $Path -PassThru

Write-Host "VHD mounted, initializing..."
# Get the disk object
$disk = $diskImage | Get-Disk -ErrorAction Stop

# Initialize the disk
$disk | Initialize-Disk -PartitionStyle MBR -ErrorAction Stop

Write-Host "Disk initialized, creating partition..."
# Create a new partition on the disk
$partition = $disk | New-Partition -UseMaximumSize -ErrorAction Stop

Write-Host "Partition created, assigning drive letter $DriveLetter"
# Assign a drive letter to the partition
$partition | Set-Partition -NewDriveLetter $DriveLetter -ErrorAction Stop

Write-Host "Drive letter assigned, formatting as Dev Drive..."
# format as a dev drive, output the result
format ${DriveLetter}: /devdrv /q /y /v:DevDrive
fsutil devdrv query ${DriveLetter}:

Write-Host "Dev Drive formatted, creating packages folders and setting machine env vars..."
# create the various package folders and set their environment variables
mkdir ${DriveLetter}:\packages\npm
setx /M npm_config_cache ${DriveLetter}:\packages\npm
mkdir ${DriveLetter}:\packages\vcpkg
setx /M VCPKG_DEFAULT_BINARY_CACHE ${DriveLetter}:\packages\vcpkg
mkdir ${DriveLetter}:\.nuget\packages
setx /M NUGET_PACKAGES ${DriveLetter}:\.nuget\packages
mkdir ${DriveLetter}:\packages\pip
setx /M PIP_CACHE_DIR ${DriveLetter}:\packages\pip
mkdir ${DriveLetter}:\packages\cargo
setx /M CARGO_HOME ${DriveLetter}:\packages\cargo
mkdir ${DriveLetter}:\packages\maven
setx /M MAVEN_OPTS "-Dmaven.repo.local=${DriveLetter}:\packages\maven %MAVEN_OPTS%"