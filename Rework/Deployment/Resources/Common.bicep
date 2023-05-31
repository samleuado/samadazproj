// General
param location string
param u4costId string = ''
param resourceGroupName string
param apiManagementName string
param apiManagementWithCertificateName string
param isPrimaryEnvironment bool

// Application Insights
param appInsightsName string
param appInsightsLocation string
param actionGroupMails array

// Certificate
param certificateName string
param certificateKeyVaultResourceGroupName string
param certificateKeyVaultName string

// KeyVault
param idsKeyVaultName string
param servicePrincipalID string

// StorageAccount
@description('Container name for flow events storage')
param flowEventsContainer string = 'flow-events-storage'
@description('Storage Account replication')
param storageAccountSkuReplication string

// CosmosDb
@description('CosmosDB secondary region for multi-region writes')
param cosmosDbSecondaryRegion string

// ApiManagement
param idsUrl string
param internalClientId string 
param apiUrl string
param webhookUrl string
param webhookV2Url string
param ekOwnerEmail string
param ekOwnerName string
param enableMTLS bool

// Redis
param redisCacheSku string
param redisCacheCapacity int

// AppServicePlan
param noScaleAppServiceTier string
param flowRuntimeAppServiceTier string
param flowRuntimeMaxInstances string
param userQueriesAppServiceTier string
param userQueriesMaxInstances string

// Workspace
param enableDiagnostic bool
param workspaceName string
param workspaceResourceGroup string

// Certificate
var certificateResourceName = '${resourceGroupName}-certificate'

// StorageAccount Variables
var storageAccountName = replace(resourceGroupName, '-', '')

// EventGrid Variables
var eventGridTopicName = resourceGroupName

// Service Plan Variables
var flowRuntimeAppServicePlanName = '${resourceGroupName}-flow-runtime'
var noScaleAppServicePlanName = '${resourceGroupName}-no-scale'
var consumptionAppServicePlanName = '${resourceGroupName}-consumption'
var userQueriesAppServicePlanName = '${resourceGroupName}-user-queries'

var servicePlans = [ 
  flowRuntimeAppServicePlanName
  noScaleAppServicePlanName
  consumptionAppServicePlanName
  userQueriesAppServicePlanName
]

targetScope = 'subscription'

resource ResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  location: location
  name: resourceGroupName
}

resource CertificateKeyvault 'Microsoft.KeyVault/vaults@2016-10-01' existing = {
  name: certificateKeyVaultName
  scope: resourceGroup(certificateKeyVaultResourceGroupName)
}

module Certificate 'Components/certificate.bicep' = {
  scope: ResourceGroup
  name: '${resourceGroupName}-certificate'
  dependsOn:  [
    CertificateKeyvault
  ]
  params: {
    location: location
    u4costId: u4costId
    certificateKeyVaultId: CertificateKeyvault.id
    certificateName: certificateName
    certificateResourceName: certificateResourceName
  }
}

module AppInsights 'Components/applicationInsights.bicep' = {
  scope: ResourceGroup
  name: '${resourceGroupName}-insights'
  params: {
    location: appInsightsLocation
    u4costId: u4costId
    resourceName: appInsightsName
    actionGroupMails: actionGroupMails
    workspaceName: workspaceName
    workspaceResourceGroup: workspaceResourceGroup
  }
}

module BasicMetricsAlerts 'Components/basicMetricAlerts.bicep' = {
  scope: ResourceGroup
  dependsOn:  [
    AppInsights
    GeneralAppServicePlan
  ]
  name: 'AlertMetrics'
  params: {
    actionGroupId: AppInsights.outputs.actionGroupId
    servicePlanNames: servicePlans
    appInsightsLocation: appInsightsLocation
    appInsightsName: appInsightsName
    u4costId: u4costId
  }
}

module GeneralAppServicePlan 'Components/appServicePlan.bicep' = {
  scope: ResourceGroup
  name: '${resourceGroupName}-service-plans'
  params: {
    location: location
    u4costId: u4costId
    consumptionAppServicePlanName: consumptionAppServicePlanName
    flowRuntimeAppServicePlanName: flowRuntimeAppServicePlanName
    flowRuntimeAppServiceTier: flowRuntimeAppServiceTier
    flowRuntimeMaxInstances: flowRuntimeMaxInstances
    noScaleAppServicePlanName: noScaleAppServicePlanName
    noScaleAppServiceTier: noScaleAppServiceTier
    userQueriesAppServicePlanName: userQueriesAppServicePlanName
    userQueriesAppServiceTier: userQueriesAppServiceTier
    userQueriesMaxInstances: userQueriesMaxInstances
  }
}

module KeyVault 'Components/keyvault-template.bicep' = {
  scope: ResourceGroup
  name: '${resourceGroupName}-keyvault'
  params: {
    location: location
    u4costId: u4costId
    idsKeyVaultName: idsKeyVaultName
    keyVaultName: resourceGroupName
    servicePrincipalID: servicePrincipalID
  }
}

module StorageAccount 'Components/storageAccount.bicep' = {
  scope: ResourceGroup
  name: '${resourceGroupName}-storage'
  params: {
    location: location
    u4costId: u4costId
    isPrimaryEnvironment: isPrimaryEnvironment
    storageName: storageAccountName
    flowEventsContainer: flowEventsContainer
    storageAccountSkuReplication: storageAccountSkuReplication
    enableDiagnostic: enableDiagnostic
    workspaceName: workspaceName
    workspaceResourceGroup: workspaceResourceGroup
  }
}

module CosmosDb 'Components/cosmosDb.bicep' = {
  scope: ResourceGroup
  name: '${resourceGroupName}-cosmosdb'
  params: {
    location: location
    u4costId: u4costId
    isPrimaryEnvironment: isPrimaryEnvironment
    resourceName: resourceGroupName
    secondaryRegion: cosmosDbSecondaryRegion
    enableDiagnostic: enableDiagnostic
    workspaceName: workspaceName
    workspaceResourceGroup: workspaceResourceGroup
  }
}

module EventGridTopic 'Components/eventGridTopic.bicep' = {
  scope: ResourceGroup
  name:'${resourceGroupName}-eventgrid'
  params: {
    location: location
    u4costId: u4costId
    isPrimaryEnvironment: isPrimaryEnvironment
    topicName: eventGridTopicName
  }
}

resource KeyVaultResource 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: resourceGroupName
  scope: ResourceGroup
}

module ApiManagement 'Components/apiManagement.bicep' = {
  scope: ResourceGroup
  name: '${resourceGroupName}-serverless-gateway'
  params: {
    location: location
    ekOwnerEmail: ekOwnerEmail
    ekOwnerName: ekOwnerName
    apiManagementName: apiManagementName
    apiManagementNamedValueExtensionsKitUri: apiUrl
    apiManagementNamedValueExtensionsKitWebhookUri: webhookUrl
    apiManagementNamedValueExtensionsKitWebhookV2Uri: webhookV2Url
    ekInternalClientId: internalClientId
    ekInternalClientSecret: KeyVaultResource.getSecret('${internalClientId}-secret')
    idsUri: idsUrl
    u4costId: u4costId
  }
}

module ApiManagementWithCertificateFirstDeployment 'Components/apiManagementWithCertificate.bicep' = if (enableMTLS){
  scope: ResourceGroup
  name: '${resourceGroupName}-serverless-mtls-gateway-first'
  params: {
    location: location
    ekOwnerEmail: ekOwnerEmail
    ekOwnerName: ekOwnerName
    apiManagementName: apiManagementWithCertificateName
    apiManagementNamedValueExtensionsKitUri: apiUrl
    apiManagementNamedValueExtensionsKitWebhookUri: webhookUrl
    apiManagementNamedValueExtensionsKitWebhookV2Uri: webhookV2Url
    ekInternalClientId: internalClientId
    ekInternalClientSecret: KeyVaultResource.getSecret('${internalClientId}-secret')
    idsUri: idsUrl
    u4costId: u4costId
    enableMTLS: false
  }
}

module ApiManagementWithCertificate 'Components/apiManagementWithCertificate.bicep' = if (enableMTLS){
  scope: ResourceGroup
  name: '${resourceGroupName}-serverless-mtls-gateway'
  dependsOn:  [
    ApiManagementWithCertificateFirstDeployment
  ]
  params: {
    location: location
    ekOwnerEmail: ekOwnerEmail
    ekOwnerName: ekOwnerName
    apiManagementName: apiManagementWithCertificateName
    apiManagementNamedValueExtensionsKitUri: apiUrl
    apiManagementNamedValueExtensionsKitWebhookUri: webhookUrl
    apiManagementNamedValueExtensionsKitWebhookV2Uri: webhookV2Url
    ekInternalClientId: internalClientId
    ekInternalClientSecret: KeyVaultResource.getSecret('${internalClientId}-secret')
    idsUri: idsUrl
    u4costId: u4costId
    enableMTLS: true
  }
}

module Redis 'Components/redis.bicep' = {
  scope: ResourceGroup
  name: '${resourceGroupName}-redis'
  params: {
    location: location
    isPrimaryEnvironment: isPrimaryEnvironment
    redisCacheName: resourceGroupName
    redisCacheSKU: redisCacheSku
    redisCacheCapacity: redisCacheCapacity
    existingDiagnosticsStorageAccountName: storageAccountName
    existingDiagnosticsStorageAccountResourceGroup: ResourceGroup.name
  }
}
