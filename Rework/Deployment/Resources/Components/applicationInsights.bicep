@description('Extension Kit Application Insights instance name')
param resourceName string
param actionGroupMails array = []

@description('Extension Kit Application Insights location')
param location string
param u4costId string = ''

param workspaceName string
param workspaceResourceGroup string

targetScope = 'resourceGroup'

var actionGroupName = '${resourceGroup().name}-ActionGroup'
var workspaceId = resourceId(workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)

resource Insights_Resource 'Microsoft.Insights/components@2020-02-02' = {
  name: resourceName
  location: location
  tags: {
    displayName: 'Extensions Kit Application Insights'
    U4COSTID: u4costId
  }
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspaceId
  }
  dependsOn: []
  kind: 'web'
}

resource ActionGroup 'Microsoft.Insights/actionGroups@2018-03-01' = {
  name: actionGroupName
  location: 'global'
  tags: {
    U4COSTID: u4costId
  }
  properties: {
    groupShortName: 'EK-Monitor'
    enabled: true
    smsReceivers: []
    emailReceivers: [for (item, j) in actionGroupMails: {
      name: '${resourceName}-Admin (${j})'
      emailAddress: item
    }]
    webhookReceivers: []
  }
}

resource ServiceHealthActivityLogAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: 'ServiceHealthActivityLogAlert'
  location: 'Global'
  tags: {
    U4COSTID: u4costId
  }
  properties: {
    description: 'Service Health Activity Log Alert'
    enabled: true
    scopes: [
      resourceGroup().id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'ServiceHealth'
        }
        {
          field: 'properties.incidentType'
          equals: 'Incident'
        }
        {
          anyOf: [
            {
              field: 'properties.cause'
              equals: 'PlatformInitiated'
              containsAny: null
            }
          ]
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: ActionGroup.id
        }
      ]
    }
  }
}

resource AutoscaleActivityLogAlert 'Microsoft.Insights/activityLogAlerts@2017-04-01' = {
  name: 'AutoscaleActivityLogAlert'
  location: 'Global'
  tags: {
    U4COSTID: u4costId
  }
  properties: {
    enabled: true
    scopes: [
      resourceGroup().id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Autoscale'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: ActionGroup.id
        }
      ]
    }
  }
}

resource Microsoft_Insights_diagnosticSettings_resourceName 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: Insights_Resource
  name: resourceName
  properties: {
    logs: [
      {
        category: 'AppAvailabilityResults'
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: false
        retentionPolicy: {
          days: 90
          enabled: false
        }
      }
    ]
    workspaceId: workspaceId
  }
}

output appInsightsInstrumentationKey string = Insights_Resource.properties.InstrumentationKey
output actionGroupId string = ActionGroup.id
