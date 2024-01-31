targetScope = 'subscription'

param deploymentSuffix string = ''

param resourceGroupName string
@allowed([
  'australiaeast'
  'canadacentral'
  'westeurope'
  'japaneast'
  'uksouth'
  'eastus'
  'eastus2'
  'southcentralus'
  'westus3'
  'centralindia'
  'eastasia'
  'northeurope'
  'koreacentral'
])
param location string = 'westus3'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: '${resourceGroupName}${deploymentSuffix}'
}

param devCenterName string
param userAssignedIdentityName string = 'devbox-image-builder'
param windows365PrincipalId string
param storageAccountName string
param imagePublisherName string
param imageOfferName string = 'Developer'
param imageSkuName string = 'Windows-DevTools'
param devCenterProjectName string = 'default'
param imageTemplateName string = 'devbox-template'

module rgDefinition 'deployment.bicep' = {
  name: guid(rg.name)
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
  }
}
