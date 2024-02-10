param(
    [string]$resourceGroup,
    [string]$imageName = 'devbox-template',
    [string]$galleryName='devbox_gallery',
    [string]$definitionName='devbox',
    [switch]$nobuild
)

if (-not $nobuild)
{
    # Execute a build on the shared image
    az image builder run -g $resourceGroup -n $imageName
}

# Get the latest version of the image
$latestVersion = az sig image-version list -i $definitionName -r $galleryName -g $resourceGroup --query "[-1].name" -o tsv

# Get all versions of the image
$imageVersions = az sig image-version list -i $definitionName -r $galleryName -g $resourceGroup --query "[].name" -o tsv

# Update replications for versions that are not the latest
foreach ($version in $imageVersions)
{
    if ($version -ne $latestVersion)
    {
        $numOfReplicas = az sig image-version show -i $definitionName -r $galleryName -g $resourceGroup -e $version --query "publishingProfile.replicaCount" -o tsv
        if ($numOfReplicas -ne 1)
        {
            Write-Output "Updating replica count for $galleryName/$definitionName/$version (trimming $($numOfReplicas-1))..."
            az sig image-version update -i $definitionName -r $galleryName -g $resourceGroup -e $version --replica-count 1 --no-wait
        }
    }
}