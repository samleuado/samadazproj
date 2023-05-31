@description('CosmosDB resource name')
param resourceName string

param isPrimaryEnvironment bool

@description('CosmosDB read consistency level')
param cosmosDbConsistencyLevelName string = 'Session'

@description('CosmosDB maximum lag time')
param cosmosDbConsistencyLevelMaxIntervalInSeconds int = 5

@description('CosmosDB maximum lag operations')
param cosmosDbConsistencyLevelMaxStalenessPrefix int = 100
param u4costId string = ''
param cosmosDbDatabaseName string = 'extensionskit'

param enableDiagnostic bool
param workspaceName string
param workspaceResourceGroup string

@description('CosmosDB secondary region for multi-region writes')
param secondaryRegion string = ''

param location string = ''

var workspaceId = resourceId(workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)
var emptyArray = []
var locations = [
  {
    locationName: location
    failoverPriority: 0
  }
]
var secondaryLocation = {
  locationName: secondaryRegion
  failoverPriority: 1
}

resource resourceName_resource 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' = if(isPrimaryEnvironment) {
  kind: 'GlobalDocumentDB'
  name: resourceName
  location: location
  tags: {
    U4COSTID: u4costId
  }
  properties: {
    enableMultipleWriteLocations: (!empty(secondaryRegion))
    isVirtualNetworkFilterEnabled: false
    virtualNetworkRules: []
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: cosmosDbConsistencyLevelName
      maxIntervalInSeconds: cosmosDbConsistencyLevelMaxIntervalInSeconds
      maxStalenessPrefix: cosmosDbConsistencyLevelMaxStalenessPrefix
    }
    locations: concat(locations, (empty(secondaryRegion) ? emptyArray : array(secondaryLocation)))
    capabilities: []
  }
  dependsOn: []
}

resource resourceName_cosmosDbDatabaseName 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-10-15' = {
  parent: resourceName_resource
  name: cosmosDbDatabaseName
  properties: {
    resource: {
      id: cosmosDbDatabaseName
    }
  }
}

resource Microsoft_Insights_diagnosticSettings_resourceName 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = if (enableDiagnostic) {
  scope: resourceName_resource
  name: resourceName
  properties: {
    logs: [
      {
        category: 'DataPlaneRequests'
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: true
        }
      }
      {
        category: 'QueryRuntimeStatistics'
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: true
        }
      }
      {
        category: 'PartitionKeyStatistics'
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: true
        }
      }
      {
        category: 'PartitionKeyRUConsumption'
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: true
        }
      }
      {
        category: 'ControlPlaneRequests'
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'Requests'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 90
        }
      }
    ]
    workspaceId: workspaceId
  }
}
