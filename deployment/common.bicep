@export()
type poolLocation = {
  location: string
  timeZone: string
}

@export()
var defaultScheduleName = 'default'

@export()
func makeScheduleFor(timeZone string) object => {
  type: 'StopDevBox'
  frequency: 'Daily'
  time: '21:00'
  timeZone: timeZone
  state: 'Enabled'
}

@export()
func getPoolPropertiesFor(definitionName string, regions array) object => {
  devBoxDefinitionName: definitionName
  licenseType: 'Windows_Client'
  localAdministrator: 'Enabled'
  virtualNetworkType: 'Managed'
  singleSignOnStatus: 'Disabled'
  networkConnectionName: 'managedNetwork'
  managedVirtualNetworkRegions: regions
}
