param imageGalleryName string = 'DevBoxGallery'

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
param userAssignedIdentityName string = 'devbox-image-builder'
param windows365PrincipalId string
param storageAccountName string
param imagePublisherName string
param imageOfferName string = 'Developer'
param imageSkuName string = 'Windows-DevTools'
param devCenterProjectName string = 'default'
param imageTemplateName string = 'devbox-template'

resource aibRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: 'devbox-image-builder-role'
  properties: {
    roleName: 'DevBox Image Builder Role'
    description: 'Custom role for imagebuilder to deploy images etc. to Gallery etc.'
    assignableScopes: [
      resourceGroup().id
    ]
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
        notActions: []
      }
    ]
  }
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userAssignedIdentityName
  location: location
}

resource rgDcRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, userAssignedIdentity.id, aibRole.id)
  properties: {
    principalId: userAssignedIdentity.properties.principalId
    roleDefinitionId: aibRole.id
  }
  scope: resourceGroup()
}

resource windows365RoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(windows365PrincipalId)
  properties: {
    principalId: windows365PrincipalId
    roleDefinitionId: 'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader role definition ID
  }
  scope: gallery
}

resource galleryDcRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(gallery.id, userAssignedIdentity.id, aibRole.id)
  properties: {
    principalId: userAssignedIdentity.properties.principalId
    roleDefinitionId: aibRole.id
  }
  scope: gallery
}

resource gallery 'Microsoft.Compute/galleries@2022-08-03' = {
  name: imageGalleryName
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
    name: 'Default'
    properties: {
      galleryResourceId: gallery.id
    }
  }
}

resource galleryDcManagedRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(gallery.id, devCenter.id, 'contributor')
  properties: {
    principalId: devCenter.identity.principalId
    roleDefinitionId: 'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor role definition ID
  }
  scope: gallery
}

resource project 'Microsoft.DevCenter/projects@2023-10-01-preview' = {
  name: devCenterProjectName
  location: location
  properties: {
    description: 'My project description'
    devCenterId: devCenter.id
  }

  resource scusProjectPool 'pools' = {
    location: location
    name: 'brazil-scus-win-blank'

    properties: {
      devBoxDefinitionName: blankBoxDefinition.name
      licenseType: 'Windows_Client'
      localAdministrator: 'Enabled'
      virtualNetworkType: 'Managed'
      singleSignOnStatus: 'Disabled'
      networkConnectionName: 'managedNetwork'
      stopOnDisconnect: {
        gracePeriodMinutes: 60
        status: 'Enabled'
      }
      managedVirtualNetworkRegions: [
        'southcentralus'
      ]
    }

    resource schedule 'schedules@2023-10-01-preview' = {
      name: 'schedule'
      properties: {
        type: 'StopDevBox'
        frequency: 'Daily'
        time: '21:00'
        timeZone: 'America/Guatemala'
        state: 'Enabled'
      }
    }
  }

  resource eastUsProjectPool 'pools' = {
    location: location
    name: 'eastus-win-blank'

    properties: {
      devBoxDefinitionName: blankBoxDefinition.name
      licenseType: 'Windows_Client'
      localAdministrator: 'Enabled'
      virtualNetworkType: 'Managed'
      singleSignOnStatus: 'Disabled'
      networkConnectionName: 'managedNetwork'
      stopOnDisconnect: {
        gracePeriodMinutes: 60
        status: 'Enabled'
      }
      managedVirtualNetworkRegions: [
        'eastus'
        'eastus2'
      ]
    }

    resource schedule 'schedules@2023-10-01-preview' = {
      name: 'schedule'
      properties: {
        type: 'StopDevBox'
        frequency: 'Daily'
        time: '21:00'
        timeZone: 'America/New_York'
        state: 'Enabled'
      }
    }
  }

  resource westusProjectPool 'pools' = {
    location: location
    name: 'westus-win-blank'

    properties: {
      devBoxDefinitionName: blankBoxDefinition.name
      licenseType: 'Windows_Client'
      localAdministrator: 'Enabled'
      virtualNetworkType: 'Managed'
      singleSignOnStatus: 'Disabled'
      networkConnectionName: 'managedNetwork'
      stopOnDisconnect: {
        gracePeriodMinutes: 60
        status: 'Enabled'
      }
      managedVirtualNetworkRegions: [
        'westus3'
      ]
    }

    resource schedule 'schedules@2023-10-01-preview' = {
      name: 'schedule'
      properties: {
        type: 'StopDevBox'
        frequency: 'Daily'
        time: '21:00'
        timeZone: 'America/Los_Angeles'
        state: 'Enabled'
      }
    }
  }

}

resource blankBoxDefinition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2023-04-01' = {
  location: location
  name: 'Blank-Win-VS-Med-16cpu-64gbRAM-256GB'
  parent: devCenter
  properties: {
    hibernateSupport: 'Enabled'
    imageReference: {
      id: '${devCenter::devCenterGalleryMapping.id}/images/microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
    }
  }
}

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
        runOutputName: 'runOutputImageVersion'
        type: 'SharedImage'
        excludeFromLatest: false
        replicationRegions: [
          'westus3'
        ]
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
          'git clone https://gist.github.com/192ae5cd666b87b2adbe6f4c6d9cab0e.git c:\\scripts --depth 1 -q'
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
        inline: [
          'c:\\scripts\\2.Configure.ps1 "${storageAccount.listKeys().keys[1].value}" -account ${storageAccountName}'
        ]
        runAsSystem: true
        runElevated: true
        validExitCodes: [ 0, 1 ]
      }
      {
        name: 'New Deprovisioning script'
        type: 'File'
        sourceUri: 'https://gist.githubusercontent.com/brandonh-msft/192ae5cd666b87b2adbe6f4c6d9cab0e/raw/DeprovisioningScript.ps1'
        destination: 'c:\\DeprovisioningScript.ps1'
      }
    ]
  }

  resource imageTrigger 'triggers' = {
    name: 'imageTrigger'
    properties: {
      kind: 'SourceImage'
    }
  }
}
