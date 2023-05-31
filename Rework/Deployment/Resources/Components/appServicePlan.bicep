@description('Extension Kit Linux App Service Plan for services involved in Flow Execution')
param flowRuntimeAppServicePlanName string

@description('Extension Kit Linux App Service Plan for resources that cannot scale')
param noScaleAppServicePlanName string

@description('Extension Kit Consumption plan for functions')
param consumptionAppServicePlanName string

@description('Extension Kit User Queries plan for Portal and FlowHistory-reads')
param userQueriesAppServicePlanName string
param noScaleAppServiceTier string = 'B2'
param flowRuntimeAppServiceTier string = 'B2'
param userQueriesAppServiceTier string = 'B2'
param flowRuntimeMaxInstances string = '2'
param userQueriesMaxInstances string = '2'
param u4costId string = ''
param location string

targetScope = 'resourceGroup'

var tiers = {
  B1: {
    Tier: 'Basic'
    Name: 'B1'
  }
  B2: {
    Tier: 'Basic'
    Name: 'B2'
  }
  S2: {
    Tier: 'Standard'
    Name: 'S2'
  }
  P1v2: {
    Tier: 'PremiumV2'
    Name: 'P1v2'
  }
  P2v2: {
    Tier: 'PremiumV2'
    Name: 'P2v2'
  }
  P3v2: {
    Tier: 'PremiumV2'
    Name: 'P3v2'
  }
}

resource noScaleAppServicePlanName_resource 'Microsoft.Web/serverfarms@2019-08-01' = {
  name: noScaleAppServicePlanName
  location: location
  kind: 'linux'
  tags: {
    U4COSTID: u4costId
  }
  sku: tiers[noScaleAppServiceTier]
}

resource userQueriesAppServicePlanName_resource 'Microsoft.Web/serverfarms@2019-08-01' = {
  name: userQueriesAppServicePlanName
  location: location
  kind: 'linux'
  tags: {
    U4COSTID: u4costId
  }
  sku: tiers[userQueriesAppServiceTier]
}

resource userQueriesAppServicePlanName_settings 'Microsoft.Insights/autoscalesettings@2015-04-01' = if (userQueriesAppServicePlanName != 'B2') {
  name: '${userQueriesAppServicePlanName}-settings'
  location: location
  properties: {
    enabled: true
    targetResourceUri: userQueriesAppServicePlanName_resource.id
    profiles: [
      {
        name: 'Default'
        capacity: {
          minimum: '1'
          maximum: userQueriesMaxInstances
          default: '1'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: userQueriesAppServicePlanName_resource.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT10M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 60
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT10M'
            }
          }
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: userQueriesAppServicePlanName_resource.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT1H'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: 40
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT1H'
            }
          }
        ]
      }
    ]
  }
}

resource flowRuntimeAppServicePlanName_resource 'Microsoft.Web/serverfarms@2019-08-01' = {
  name: flowRuntimeAppServicePlanName
  location: location
  kind: 'linux'
  tags: {
    U4COSTID: u4costId
  }
  sku: tiers[flowRuntimeAppServiceTier]
}

resource flowRuntimeAppServicePlanName_settings 'Microsoft.Insights/autoscalesettings@2015-04-01' = if (flowRuntimeAppServiceTier != 'B2') {
  name: '${flowRuntimeAppServicePlanName}-settings'
  location: location
  properties: {
    enabled: true
    targetResourceUri: flowRuntimeAppServicePlanName_resource.id
    profiles: [
      {
        name: 'Default'
        capacity: {
          minimum: '1'
          maximum: flowRuntimeMaxInstances
          default: '1'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: flowRuntimeAppServicePlanName_resource.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT10M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 60
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT10M'
            }
          }
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: flowRuntimeAppServicePlanName_resource.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT1H'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: 40
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT1H'
            }
          }
        ]
      }
    ]
  }
}

resource consumptionAppServicePlanName_resource 'Microsoft.Web/serverfarms@2019-08-01' = {
  name: consumptionAppServicePlanName
  location: location
  tags: {
    U4COSTID: u4costId
  }
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}
