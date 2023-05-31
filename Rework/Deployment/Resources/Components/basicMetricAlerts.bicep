@description('The action group for the alert actions')
param actionGroupId string = ''

@description('A list of [Microsoft.Web/serverfarms] service plan names for creating alerts')
param servicePlanNames array = []

param appInsightsLocation string
param u4costId string = ''
param appInsightsName string = ''

var appInsightsId = resourceId('Microsoft.Insights/components', (empty(appInsightsName) ? resourceGroup().name : appInsightsName))
var logAlertsTag = 'hidden-link:/${appInsightsId}'
var queriesFor = [
  'exceptions'
  'traces'
]

resource servicePlanNames_CPU_Usage 'Microsoft.Insights/metricAlerts@2018-03-01' = [for item in servicePlanNames: if (length(servicePlanNames) > 0) {
  name: '${item}-CPU-Usage'
  location: 'global'
  tags: {
    U4COSTID: u4costId
  }
  properties: {
    description: 'CPU usage metric for service plans under the resource group'
    severity: 2
    enabled: true
    scopes: [
      resourceId('Microsoft.Web/serverfarms', item)
    ]
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'DynamicThresholdCriterion'
          name: '1st criterion'
          metricName: 'CpuPercentage'
          dimensions: [
            {
              name: 'Instance'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          failingPeriods: {
            numberOfEvaluationPeriods: 4
            minFailingPeriodsToAlert: 3
          }
          operator: 'GreaterThan'
          alertSensitivity: 'Medium'
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroupId
      }
    ]
  }
}]

resource servicePlanNames_MemoryPercentage 'Microsoft.Insights/metricAlerts@2018-03-01' = [for item in servicePlanNames: if (length(servicePlanNames) > 0) {
  name: '${item}-MemoryPercentage'
  location: 'global'
  tags: {
    U4COSTID: u4costId
  }
  properties: {
    description: 'Memory usage metric for service plans under the resource group'
    severity: 2
    enabled: true
    scopes: [
      resourceId('Microsoft.Web/serverfarms', item)
    ]
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'DynamicThresholdCriterion'
          name: '1st criterion'
          metricName: 'MemoryPercentage'
          dimensions: [
            {
              name: 'Instance'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          failingPeriods: {
            numberOfEvaluationPeriods: 4
            minFailingPeriodsToAlert: 3
          }
          operator: 'GreaterThan'
          alertSensitivity: 'Medium'
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroupId
      }
    ]
  }
}]

resource Critical_queriesFor_real_time_alerts 'Microsoft.Insights/scheduledQueryRules@2018-04-16' = [for item in queriesFor: {
  name: 'Critical ${item} real-time alerts'
  location: appInsightsLocation
  tags: {
    '${logAlertsTag}': 'Resource'
    U4COSTID: u4costId
  }
  properties: {
    description: 'Critical exceptions real-time alert'
    enabled: 'true'
    source: {
      query: '${item} | where  severityLevel >= 3 | where customDimensions.CategoryName != "Microsoft.Extensions.Diagnostics.HealthChecks.DefaultHealthCheckService" | where customDimensions.Category != "Function.HealthCheckFunction.User" | where customDimensions.Category != "Microsoft.Extensions.Diagnostics.HealthChecks.DefaultHealthCheckService"'
      dataSourceId: appInsightsId
      queryType: 'ResultCount'
    }
    schedule: {
      frequencyInMinutes: 30
      timeWindowInMinutes: 40
    }
    action: {
      'odata.type': 'Microsoft.WindowsAzure.Management.Monitoring.Alerts.Models.Microsoft.AppInsights.Nexus.DataContracts.Resources.ScheduledQueryRules.AlertingAction'
      severity: '0'
      aznsAction: {
        actionGroup: [
          actionGroupId
        ]
        emailSubject: '${resourceGroup().name}: a critical error has occurred'
        customWebhookPayload: '{ "alertname":"#alertrulename", "IncludeSearchResults":true }'
      }
      trigger: {
        thresholdOperator: 'GreaterThan'
        threshold: 0
      }
    }
  }
}]
