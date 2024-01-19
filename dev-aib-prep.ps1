<#
.SYNOPSIS
Creates a dev drive for usage with Azure Image Builder

.DESCRIPTION
Creates a new dev drive and mounts it to X: then sets up the various package folders and environment variables.

.EXAMPLE
.\dev-aib-prep.ps1 Path c:\newdevdrive.vhdx
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
})][string] $DriveLetter="D" # Drive letter to mount the new VHD to
)

$ErrorActionPreference = "Stop"

New-VHD -Path $Path -SizeBytes 100GB -Dynamic -ErrorAction Stop
$diskImage = Mount-DiskImage -ImagePath $Path -PassThru

# Get the disk object
$disk = $diskImage | Get-Disk -ErrorAction Stop

# Initialize the disk
$disk | Initialize-Disk -PartitionStyle MBR -ErrorAction Stop

# Create a new partition on the disk
$partition = $disk | New-Partition -UseMaximumSize -ErrorAction Stop

# Assign a drive letter to the partition
$partition | Set-Partition -NewDriveLetter $DriveLetter -ErrorAction Stop

# format as a dev drive, output the result
format ${DriveLetter}: /devdrv /q /y /v:DevDrive
fsutil devdrv query ${DriveLetter}:

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

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install notepadplusplus -y
choco install postman -y
choco install vscode -y
choco install azure-cli -y
choco install gpg4win -y
choco install 7zip -y
choco install github-cli -y
choco install powershell-core -y
choco install git-credential-manager -y
choco install docker-desktop -y
choco install powertoys -y
choco install microsoftazurestorageexplorer -y
choco install python3 -y
choco install golang -y