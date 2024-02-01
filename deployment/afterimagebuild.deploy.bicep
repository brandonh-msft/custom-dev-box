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

param devCenterName string
param devCenterProjectName string

resource devCenter 'Microsoft.DevCenter/devcenters@2023-04-01' existing = {
  name: devCenterName

  resource devReadyBoxDefinition 'devboxdefinitions' = {
    location: location
    name: 'DevReady-Win-VS-Med-16cpu-64gbRAM-256GB'
    properties: {
      hibernateSupport: 'Enabled'
      imageReference: {
        id: '${resourceId('Microsoft.DevCenter/devcenters/galleries', devCenter.name, 'devboximages3')}/images/devbox'
      }
      sku: {
        name: 'general_i_16c64gb256ssd_v2'
      }
    }
  }
}

var defaultScheduleName = 'default'
func makeScheduleFor(timeZone string) object => {
  type: 'StopDevBox'
  frequency: 'Daily'
  time: '21:00'
  timeZone: timeZone
  state: 'Enabled'
}

func getPoolPropertiesFor(definitionName string, regions array) object => {
  devBoxDefinitionName: definitionName
  licenseType: 'Windows_Client'
  localAdministrator: 'Enabled'
  virtualNetworkType: 'Managed'
  singleSignOnStatus: 'Disabled'
  networkConnectionName: 'managedNetwork'
  managedVirtualNetworkRegions: regions
}

resource project 'Microsoft.DevCenter/projects@2023-10-01-preview' existing = {
  name: devCenterProjectName

  resource westusDevReadyProjectPool 'pools' = {
    location: location
    name: 'westus-win-devready'

    properties: getPoolPropertiesFor(devCenter::devReadyBoxDefinition.name, [ 'westus3' ])

    resource schedule 'schedules' = {
      name: defaultScheduleName
      properties: makeScheduleFor('America/Los_Angeles')
    }
  }

  resource eastUsDevReadProjectPool 'pools' = {
    location: location
    name: 'eastus-win-devready'

    properties: getPoolPropertiesFor(devCenter::devReadyBoxDefinition.name, [ 'eastus2' ])

    resource schedule 'schedules' = {
      name: defaultScheduleName
      properties: makeScheduleFor('America/New_York')
    }
  }

  resource scusDevReadyProjectPool 'pools' = {
    location: location
    name: 'brazil-scus-win-devready'

    properties: getPoolPropertiesFor(devCenter::devReadyBoxDefinition.name, [ 'southcentralus' ])

    resource schedule 'schedules' = {
      name: defaultScheduleName
      properties: makeScheduleFor('America/Guatemala')
    }
  }
}
