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

var namesAndSkus = [
  {
    name: 'DevReady-Win-VS-Sm-16cpu-64gbRAM-256GB'
    sku: 'general_i_8c32gb256ssd_v2'
    size: 'small'
    canHibernate: true
  }
  {
    name: 'DevReady-Win-VS-Med-16cpu-64gbRAM-256GB'
    sku: 'general_i_16c64gb256ssd_v2'
    size: 'med'
    canHibernate: true
  }
  {
    name: 'DevReady-Win-VS-Lg-16cpu-64gbRAM-256GB'
    sku: 'general_i_32c128gb512ssd_v2'
    size: 'large'
    canHibernate: false
  }
]

resource devCenter 'Microsoft.DevCenter/devcenters@2023-04-01' existing = {
  name: devCenterName

  resource devboxdefinitions 'devboxdefinitions' = [for i in namesAndSkus: {
    location: location
    name: i.name
    properties: {
      hibernateSupport: i.canHibernate ? 'Enabled' : 'Disabled'
      imageReference: {
        id: '${resourceId('Microsoft.DevCenter/devcenters/galleries', devCenter.name, 'devboximages')}/images/devbox'
      }
      sku: {
        name: i.sku
      }
    }
  }]
}

import * as common from 'common.bicep'

resource project 'Microsoft.DevCenter/projects@2023-10-01-preview' existing = {
  name: devCenterProjectName
}

module poolDefinitions 'poolcollection.bicep' = [for i in namesAndSkus: {
  name: '${i.name}-pool'
  dependsOn: devCenter::devboxdefinitions
  params: {
    resourceLocation: location
    projectName: project.name
    poolLocations: poolLocations
    poolName: 'win-devready-${i.size}'
    devBoxDefinitionName: i.name
  }
}]
