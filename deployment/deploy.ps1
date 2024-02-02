param(
    [Parameter(Mandatory = $true)]
    [string]$region,

    [string]$suffix = "",
    [string]$subscriptionId = "",
    [string]$prevDeploymentOutputFile = $null,
    [switch]$noImageBuild,
    [switch]$noAfterBuild,
    [switch]$noGroupCreate
)

$ErrorActionPreference = "Stop"

try
{
    az version > $null
}
catch
{
    Write-Error "Azure CLI is not installed."
    exit 1
}

if (-not $subscriptionId)
{
    $subscriptionId = (az account show --query id -o tsv)
}
else
{
    az account set --subscription $subscriptionId > $null
}

if (-not (Test-Path -Path "main.parameters.json"))
{
    az bicep generate-params -f main.bicep --outfile main
    Write-Error "A main.parameters.json file was missing and has been created. Populate it with parameters for your deployment and try again."
    exit 1
}

$windows365PrincipalId = ((az ad sp list --filter "displayname eq 'Windows 365'") | ConvertFrom-Json).id
if (-not $windows365PrincipalId)
{
    Write-Error "The Windows 365 service principal was not found. Please ensure that the Windows 365 service principal is created and try again."
    exit 1
}

Write-Debug "Windows 365 service principal found with id: $windows365PrincipalId"

if (-not $prevDeploymentOutputFile)
{
    Write-Output "Deploying initial resources... (takes ~5 minutes)"
    if ($suffix.Length -gt 0)
    {
        $mainOutput = (az deployment sub create -n 'main' -l $region -f main.bicep -p main.parameters.json -p windows365PrincipalId=$windows365PrincipalId -p deploymentSuffix=$suffix -o json --only-show-errors)
    }
    else
    {
        $mainOutput = (az deployment sub create -n 'main' -l $region -f main.bicep -p main.parameters.json -p windows365PrincipalId=$windows365PrincipalId -o json --only-show-errors)
    }

    $mainOutput | Out-File -FilePath "main.deployment.json"
}
else
{
    Write-Output "Loading previous deployment..."
    $mainOutput = Get-Content $prevDeploymentOutputFile
}

$mainOutput = $mainOutput | ConvertFrom-Json
Write-Debug ($mainOutput | Out-String)

if (-not $noImageBuild)
{
    Write-Output "Building image... (this can take up to 4 hours - go take a long lunch!)"
    try
    {
    	az resource invoke-action --resource-group $mainOutput.properties.outputs.resourceGroupName.value `
        --resource-type Microsoft.VirtualMachineImages/imageTemplates `
        --name $mainOutput.properties.outputs.imageTemplateName.value `
        --action Run
    }
    catch
    {
    Write-Warning "You can rerun the script with -prevDeploymentOutputFile .\main.deployment.json to try this step again."
    }
}
else
{
    Write-Output "Skipping image build..."
}

Write-Debug resourceGroupName=$($mainOutput.properties.outputs.resourceGroupName.value)
Write-Debug locationOutput=$($mainOutput.properties.outputs.locationOutput.value)
Write-Debug devCenterName=$($mainOutput.properties.outputs.devCenterName.value)
Write-Debug projectName=$($mainOutput.properties.outputs.projectName.value)

$projectResourceId = $($mainOutput.properties.outputs.projectResourceId.value)

# Older deployments won't have the `projectResourceId` output, so have to find that based on output resources
if (-not $projectResourceId)
{
    $projectResourceId = $mainOutput.properties.outputResources | Where-Object { $_.id -match "providers/Microsoft.DevCenter/projects/[^/]*$" } | Select-Object -ExpandProperty id
}

Write-Debug projectResourceId=$projectResourceId

if (-not $noAfterBuild)
{
    Write-Output "Deploying DevBox definitions with built image... (~20 minutes *per pool location*)"
    az deployment group create -g $mainOutput.properties.outputs.resourceGroupName.value -n afterimagebuild -f afterimagebuild.bicep -p main.parameters.json `
        -p location=$($mainOutput.properties.outputs.locationOutput.value) `
        -p devCenterName=$($mainOutput.properties.outputs.devCenterName.value) `
        -p devCenterProjectName=$($mainOutput.properties.outputs.projectName.value) `
        -p windows365PrincipalId=$windows365PrincipalId `
        --only-show-errors > $null
}

$groupDisplayName = "Dev Box Users for Project $($mainOutput.properties.outputs.projectName.value)"
if (-not $noGroupCreate)
{
    $groupAlias = "$($mainOutput.properties.outputs.projectName.value.ToLower())-dev-box-users"
    Write-Output "Creating dev box users group $groupAlias ..."
    $groupDetail = (az ad group create --display-name $groupDisplayName --mail-nickname $groupAlias -o json) | ConvertFrom-Json
}
else
{
    $groupDetail = (az ad group show -g $groupDisplayName -o json) | ConvertFrom-Json
}

Write-Output "Adding current user as owner & member of group..."
$signedInUserId = (az ad signed-in-user show -o json) | ConvertFrom-Json
az ad group owner add --group $groupDetail.id --owner-object-id $signedInUserId.id > $null
az ad group member add --group $groupDetail.id --member-id $signedInUserId.id > $null

Write-Output "Granting new group User access to Dev Box project..."
az role assignment create --assignee $groupDetail.id --role "DevCenter Dev Box User" --scope $projectResourceId > $null

Write-Output "Done!"
Write-Output ""
Write-Output "You can manage your Dev Center Users by adding members to the '$groupDisplayName' group in Entra here: https://portal.azure.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Members/groupId/$($groupDetail.id)"
Write-Output "You can try our your new Dev Box environment by going to https://devbox.microsoft.com and logging in!"