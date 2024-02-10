import * as common from 'common.bicep'

param projectName string
param resourceLocation string
param poolLocations common.poolLocation[]
param poolName string

resource project 'Microsoft.DevCenter/projects@2023-10-01-preview' existing = {
  name: projectName
}
resource pools 'Microsoft.DevCenter/projects/pools@2023-10-01-preview' = [for poolLocation in poolLocations: {
  location: resourceLocation
  #disable-next-line use-parent-property // warning is invalid - can't use 'parent' w/in a loop
  name: '${project.name}/win-devready-${poolLocation.location}'

  properties: common.getPoolPropertiesFor(poolName, [ poolLocation.location ])
}]
