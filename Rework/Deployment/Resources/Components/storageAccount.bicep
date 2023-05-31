@description('Extension Kit Storage Account resource name')
param storageName string

param isPrimaryEnvironment bool

@description('Storage Account replication')
param storageAccountSkuReplication string

@description('Enable or disable Blob encryption at Rest')
param storageAccountBlobEncryptionEnabled bool = true

@description('Container name for events dead lettering')
param eventDeadLetterContainer string = 'event-dead-letter-storage'

@description('Container name for flow events storage')
param flowEventsContainer string

param enableDiagnostic bool
param workspaceName string
param workspaceResourceGroup string

param u4costId string = ''

param location string = ''

var workspaceId = resourceId(workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)

targetScope = 'resourceGroup'

resource resourceName_resource 'Microsoft.Storage/storageAccounts@2021-08-01' = if(isPrimaryEnvironment) {
  kind: 'StorageV2'
  name: storageName
  location: location
  sku: {
    name: storageAccountSkuReplication
  }
  tags: {
    U4COSTID: u4costId
  }
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: storageAccountBlobEncryptionEnabled
        }
      }
    }
  }
  dependsOn: []
}

resource diagnostic_storage 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostic) {
  scope: resourceName_resource
  name: storageName
  properties: {
    workspaceId: workspaceId
    storageAccountId: resourceName_resource.id
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' existing = {
  name: 'default'
  parent: resourceName_resource
}

resource queue 'Microsoft.Storage/storageAccounts/queueServices@2022-05-01' existing = {
  name: 'default'
  parent: resourceName_resource
}

resource diagnostic_storage_blobs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostic) {
  scope: blob
  name: storageName
  properties: {
    workspaceId: workspaceId
    storageAccountId: resourceName_resource.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource diagnostic_storage_queues 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostic) {
  scope: queue
  name: storageName
  properties: {
    workspaceId: workspaceId
    storageAccountId: resourceName_resource.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource resourceName_default_flowEventsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  name: '${storageName}/default/${flowEventsContainer}'
  dependsOn: [
    resourceName_resource
  ]
}

resource resourceName_default_eventDeadLetterContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  name: '${storageName}/default/${eventDeadLetterContainer}'
  dependsOn: [
    resourceName_resource
  ]
}

resource resourceName_default_internal_event_storage 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  name: '${storageName}/default/internal-event-storage'
  dependsOn: [
    resourceName_resource
  ]
}

resource resourceName_default 'Microsoft.Storage/storageAccounts/managementPolicies@2021-08-01' = {
  parent: resourceName_resource
  name: 'default'
  properties: {
    policy: {
      rules: [
        {
          name: 'Internal event storage blob lifecycle'
          enabled: true
          type: 'Lifecycle'
          definition: {
            filters: {
              blobTypes: [
                'blockBlob'
              ]
              prefixMatch: [
                'internal-event-storage'
              ]
            }
            actions: {
              baseBlob: {
                delete: {
                  daysAfterModificationGreaterThan: 2
                }
              }
            }
          }
        }
        {
          name: 'Flow events storage blob lifecycle'
          enabled: true
          type: 'Lifecycle'
          definition: {
            filters: {
              blobTypes: [
                'blockBlob'
              ]
              prefixMatch: [
                '${flowEventsContainer}'
              ]
            }
            actions: {
              baseBlob: {
                delete: {
                  daysAfterModificationGreaterThan: 90
                }
              }
            }
          }
        }
      ]
    }
  }
}
