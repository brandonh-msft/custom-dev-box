param deploymentSuffix string

param devCenterName string
param userAssignedIdentityName string
param windows365PrincipalId string
param storageAccountName string
param imagePublisherName string
param imageOfferName string
param imageSkuName string
param devCenterProjectName string
param imageTemplateName string
param location string

import * as common from 'common.bicep'

@minLength(1)
param poolLocations common.poolLocation[]

var readerRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
var contributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

// This one's good
resource builderRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(resourceGroup().id, 'devbox-image-builder-role', deploymentSuffix)
  properties: {
    roleName: 'DevBox Image Builder Role${deploymentSuffix != '' ? '-${deploymentSuffix}' : ''}'
    description: 'Custom role for imagebuilder to deploy images etc. to Gallery etc.'
    assignableScopes: [ resourceGroup().id ]
    permissions: [
      {
        actions: [
          'Microsoft.Compute/galleries/read'
          'Microsoft.Compute/galleries/images/read'
          'Microsoft.Compute/galleries/images/versions/read'
          'Microsoft.Compute/galleries/images/versions/write'
          'Microsoft.Compute/images/write'
          'Microsoft.Compute/images/read'
          'Microsoft.Compute/images/delete'
        ]
      }
    ]
  }
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userAssignedIdentityName
  location: location
}

resource rgBuilderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, userAssignedIdentity.id, builderRole.id, deploymentSuffix)
  properties: {
    description: '${userAssignedIdentity.name} with builder role on RG (${resourceGroup().name})'
    principalId: userAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: builderRole.id
  }
  scope: resourceGroup()
}

resource windows365RoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(windows365PrincipalId, deploymentSuffix)
  properties: {
    description: 'Win365 reader role on RG (${resourceGroup().name})'
    principalId: windows365PrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: readerRoleDefinitionId
  }
  scope: gallery
}

resource galleryBuilderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(gallery.id, userAssignedIdentity.id, builderRole.id, deploymentSuffix)
  properties: {
    description: '${userAssignedIdentity.name} with builder role on gallery (${gallery.name})'
    principalId: userAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: builderRole.id
  }
  scope: gallery
}

resource gallery 'Microsoft.Compute/galleries@2022-08-03' = {
  name: 'devbox_gallery${deploymentSuffix}'
  location: location

  resource galleryImage 'images' = {
    name: 'devbox'
    location: location
    properties: {
      architecture: 'x64'
      hyperVGeneration: 'V2'
      identifier: {
        offer: imageOfferName
        publisher: imagePublisherName
        sku: imageSkuName
      }
      osState: 'Generalized'
      osType: 'Windows'
      features: [
        {
          name: 'SecurityType'
          value: 'TrustedLaunch'
        }
        {
          name: 'IsHibernateSupported'
          value: 'True'
        }
      ]
      recommended: {
        memory: {
          min: 16
          max: 64
        }
        vCPUs: {
          min: 4
          max: 32
        }
      }
    }
  }
}

resource devCenter 'Microsoft.DevCenter/devcenters@2023-04-01' = {
  name: devCenterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }

  resource devCenterGalleryMapping 'galleries' = {
    name: 'devboximages'
    dependsOn: [ galleryDcManagedRoleAssignment ]
    properties: {
      galleryResourceId: gallery.id
    }
  }

  resource devboxdefinitions 'devboxdefinitions' = [for i in namesAndSkus: {
    location: location
    name: i.name
    properties: {
      hibernateSupport: i.canHibernate ? 'Enabled' : 'Disabled'
      imageReference: {
        id: '${resourceId('Microsoft.DevCenter/devcenters/galleries', devCenter.name, 'Default')}/images/microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
      }
      sku: {
        name: i.sku
      }
    }
  }]
}

resource galleryDcManagedRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(gallery.id, devCenter.id, 'contributor', deploymentSuffix)
  properties: {
    description: 'devCenter managed identity (${devCenter.identity.principalId}) with contributor role on gallery (${gallery.name})'
    principalId: devCenter.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: contributorRoleDefinitionId
  }
  scope: gallery
}

resource project 'Microsoft.DevCenter/projects@2023-10-01-preview' = {
  name: '${devCenterProjectName}${deploymentSuffix}'
  location: location
  properties: {
    description: 'My project description'
    devCenterId: devCenter.id
  }
}

var namesAndSkus = [
  {
    name: 'Blank-Win-VS-Sm-16cpu-64gbRAM-256GB'
    sku: 'general_i_8c32gb256ssd_v2'
    size: 'small'
    canHibernate: true
  }
  {
    name: 'Blank-Win-VS-Med-16cpu-64gbRAM-256GB'
    sku: 'general_i_16c64gb256ssd_v2'
    size: 'med'
    canHibernate: true
  }
  {
    name: 'Blank-Win-VS-Lg-16cpu-64gbRAM-256GB'
    sku: 'general_i_32c128gb512ssd_v2'
    size: 'large'
    canHibernate: false
  }
]

module poolDefinitions 'poolcollection.bicep' = [for i in namesAndSkus: {
  name: '${i.name}-pool'
  dependsOn: devCenter::devboxdefinitions
  params: {
    resourceLocation: location
    projectName: project.name
    poolLocations: poolLocations
    poolName: 'win-blank-${i.size}'
    devBoxDefinitionName: i.name
  }
}]

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    allowSharedKeyAccess: true
  }

  resource storageAccountFiles 'fileServices' = {
    name: 'default'
    properties: {
      shareDeleteRetentionPolicy: {
        enabled: true
        days: 14
      }
    }

    resource softwareShare 'shares' = {
      name: 'software'
      properties: {
        accessTier: 'Hot'
        shareQuota: 5120
        enabledProtocols: 'SMB'
      }
    }
  }
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2023-07-01' = {
  name: imageTemplateName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    distribute: [
      {
        galleryImageId: gallery::galleryImage.id
        runOutputName: 'runOutputImageVersion${deploymentSuffix}'
        type: 'SharedImage'
        excludeFromLatest: false
        replicationRegions: [ 'westus3' ]
      }
    ]
    source: {
      type: 'PlatformImage'
      offer: 'visualstudioplustools'
      publisher: 'microsoftvisualstudio'
      sku: 'vs-2022-ent-general-win11-m365-gen2'
      version: 'latest'
    }
    optimize: {
      vmBoot: {
        state: 'Enabled'
      }
    }
    vmProfile: {
      osDiskSizeGB: 128
      vmSize: 'Standard_B4ms'
    }
    customize: [
      {
        name: 'Clone scripts'
        type: 'PowerShell'
        inline: [
          'git clone https://github.com/brandonh-msft/custom-dev-box.git c:\\scripts --single-branch --recursive --depth 1 --shallow-submodules --sparse -q'
          'cd c:\\scripts'
          'git log -q'
        ]
      }
      {
        name: 'Run Setup'
        type: 'PowerShell'
        inline: [ 'c:\\scripts\\1.Setup.ps1' ]
        runAsSystem: true
        runElevated: true
        validExitCodes: [ 0, 1 ]
      }
      {
        type: 'WindowsUpdate'
      }
      {
        type: 'WindowsRestart'
      }
      {
        name: 'Run Configure'
        type: 'PowerShell'
        inline: [ 'c:\\scripts\\2.Configure.ps1 "${storageAccount.listKeys().keys[1].value}" -account ${storageAccountName}' ]
        runAsSystem: true
        runElevated: true
        validExitCodes: [ 0, 1 ]
      }
      {
        name: 'New Deprovisioning script'
        type: 'File'
        sourceUri: 'https://raw.githubusercontent.com/brandonh-msft/custom-dev-box/main/DeprovisioningScript.ps1'
        destination: 'c:\\DeprovisioningScript.ps1'
      }
    ]
  }

  resource imageTrigger 'triggers' = {
    name: 'Rebuild when Win-VS-M365 image changes'
    properties: {
      kind: 'SourceImage'
    }
  }
}

output imageTemplateName string = imageTemplate.name
output locationOutput string = location
output userAssignedIdentityIdOutput string = userAssignedIdentity.name
output galleryName string = gallery.name
output storageAccountName string = storageAccount.name
output projectName string = project.name
output projectResourceId string = project.id
output devCenterName string = devCenter.name
output resourceGroupName string = resourceGroup().name
