targetScope = 'subscription'

@description('Suffix to append onto all deployed resources that require unique names')
param deploymentSuffix string = ''

@description('The name of the resource group to create & deploy into')
param resourceGroupName string

@allowed([
  'australiaeast'
  'centralindia'
  'eastasia'
  'eastus'
  'eastus2'
  'japaneast'
  'koreacentral'
  'northeurope'
  'southcentralus'
  'uksouth'
  'westeurope'
  'westus3'
])
@description('The location to create resources in')
param location string = 'westus3'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: '${resourceGroupName}${deploymentSuffix}'
}

@description('The name of the Dev Center to create')
param devCenterName string

@description('The principal ID of the Windows 365 user in Entra; this is automatically discovered & populated by deploy.ps1')
param windows365PrincipalId string

@description('The name of the storage account to create')
param storageAccountName string

@description('The name to use as the "Publisher" on the created "DevReady" image')
param imagePublisherName string

@description('The name of the user-assigned identity to create & use for image building operations')
param userAssignedIdentityName string = 'devbox-image-builder'

@description('The name of the offer to use for the created "DevReady" image')
param imageOfferName string = 'Developer'

@description('The name of the SKU to use for the created "DevReady" image')
param imageSkuName string = 'Windows-DevTools'

@description('The name of the Dev Center project to create')
param devCenterProjectName string = 'default'

@description('The name of the image template to create')
param imageTemplateName string = 'devbox-template'

import { poolLocation } from 'common.bicep'

@minLength(1)
@description('The locations to create pools in. Timezone also required for auto-shutdown scheduling.')
param poolLocations poolLocation[]

module rgDefinition 'deployment.bicep' = {
  name: 'deployment'
  scope: rg
  params: {
    deploymentSuffix: deploymentSuffix
    devCenterName: '${devCenterName}${deploymentSuffix}'
    devCenterProjectName: '${devCenterProjectName}${deploymentSuffix}'
    imageOfferName: '${imageOfferName}${deploymentSuffix}'
    imagePublisherName: '${imagePublisherName}${deploymentSuffix}'
    imageSkuName: '${imageSkuName}${deploymentSuffix}'
    imageTemplateName: '${imageTemplateName}${deploymentSuffix}'
    location: location
    storageAccountName: '${storageAccountName}${deploymentSuffix}'
    userAssignedIdentityName: '${userAssignedIdentityName}${deploymentSuffix}'
    windows365PrincipalId: windows365PrincipalId
    poolLocations: poolLocations
  }
}

output imageTemplateName string = rgDefinition.outputs.imageTemplateName
output locationOutput string = rgDefinition.outputs.locationOutput
output userAssignedIdentityIdOutput string = rgDefinition.outputs.userAssignedIdentityIdOutput
output galleryName string = rgDefinition.outputs.galleryName
output storageAccountName string = rgDefinition.outputs.storageAccountName
output projectName string = rgDefinition.outputs.projectName
output projectResourceId string = rgDefinition.outputs.projectResourceId
output devCenterName string = rgDefinition.outputs.devCenterName
output resourceGroupName string = rg.name
