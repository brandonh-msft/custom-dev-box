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
param location string 
param devCenterName string
param devCenterProjectName string 
param poolLocations common.poolLocation[]

// Yes, these are unused. But it allows us to use the same param file for main & afterimage, simplifying the deployment script
param userAssignedIdentityName string = 'devbox-image-builder'
param windows365PrincipalId string
param storageAccountName string
param imagePublisherName string
param imageOfferName string = 'Developer'
param imageSkuName string = 'Windows-DevTools'
param imageTemplateName string = 'devbox-template'
param deploymentSuffix string = ''
param resourceGroupName string

resource devCenter 'Microsoft.DevCenter/devcenters@2023-04-01' existing = {
  name: devCenterName

  resource devReadyBoxDefinition 'devboxdefinitions' = {
    location: location
    name: 'DevReady-Win-VS-Med-16cpu-64gbRAM-256GB'
    properties: {
      hibernateSupport: 'Enabled'
      imageReference: {
        id: '${resourceId('Microsoft.DevCenter/devcenters/galleries', devCenter.name, 'devboximages')}/images/devbox'
      }
      sku: {
        name: 'general_i_16c64gb256ssd_v2'
      }
    }
  }
}

import * as common from 'common.bicep'

resource project 'Microsoft.DevCenter/projects@2023-10-01-preview' existing = {
  name: devCenterProjectName
}

resource pools 'Microsoft.DevCenter/projects/pools@2023-10-01-preview' = [for poolLocation in poolLocations: {
  parent: project
  location: location
  name: 'win-devready-${poolLocation.location}'

  properties: common.getPoolPropertiesFor(devCenter::devReadyBoxDefinition.name, [ poolLocation.location ])
}]

resource schedules 'Microsoft.DevCenter/projects/pools/schedules@2023-10-01-preview' = [for poolLocation in poolLocations: {
  #disable-next-line use-parent-property // warning is invalid - can't use 'parent' w/in a loop
  name: '${project.name}/win-devready-${poolLocation.location}/${common.defaultScheduleName}' 
  dependsOn: pools
  properties: common.makeScheduleFor(poolLocation.timeZone)
}]
