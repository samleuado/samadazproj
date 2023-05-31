@description('Specify the name of the Azure Redis Cache to create.')
param redisCacheName string

param isPrimaryEnvironment bool

@description('Location of all resources')
param location string = resourceGroup().location

@description('Specify the pricing tier of the new Azure Redis Cache.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param redisCacheSKU string = 'Basic'

@description('Specify the family for the sku. C = Basic/Standard, P = Premium.')
@allowed([
  'C'
  'P'
])
param redisCacheFamily string = 'C'

@description('Specify the size of the new Azure Redis Cache instance. Valid values: for C (Basic/Standard) family (0, 1, 2, 3, 4, 5, 6), for P (Premium) family (1, 2, 3, 4)')
@allowed([
  0
  1
  2
  3
  4
  5
  6
])
param redisCacheCapacity int = 0

@description('Specify a boolean value that indicates whether to allow access via non-SSL ports.')
param enableNonSslPort bool = false

@description('Specify a boolean value that indicates whether diagnostics should be saved to the specified storage account.')
param diagnosticsEnabled bool = false

@description('Specify the name of an existing storage account for diagnostics.')
param existingDiagnosticsStorageAccountName string

@description('Specify the resource group name of an existing storage account for diagnostics.')
param existingDiagnosticsStorageAccountResourceGroup string

resource redisCacheName_resource 'Microsoft.Cache/redis@2021-06-01' = if(isPrimaryEnvironment) {
  name: redisCacheName
  location: location
  properties: {
    enableNonSslPort: enableNonSslPort
    minimumTlsVersion: '1.2'
    sku: {
      capacity: redisCacheCapacity
      family: redisCacheFamily
      name: redisCacheSKU
    }
  }
}

resource microsoft_insights_diagnosticSettings_redisCacheName 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if(isPrimaryEnvironment) {
  scope: redisCacheName_resource
  name: redisCacheName
  properties: {
    storageAccountId: extensionResourceId('/subscriptions/${subscription().subscriptionId}/resourceGroups/${existingDiagnosticsStorageAccountResourceGroup}', 'Microsoft.Storage/storageAccounts', existingDiagnosticsStorageAccountName)
    metrics: [
      {
        timeGrain: 'AllMetrics'
        enabled: diagnosticsEnabled
        retentionPolicy: {
          days: 90
          enabled: diagnosticsEnabled
        }
      }
    ]
  }
}
