param location string
param hostingPlanName string
param sku string
param skuCode string
param workerSize string
param workerSizeId string
param numberOfWorkers string
param u4costId string

resource hostingPlanName_resource 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: hostingPlanName
  location: location
  kind: ''
  tags: {
    U4COSTID: u4costId
  }
  properties: {
    name: hostingPlanName
    workerSize: workerSize
    workerSizeId: workerSizeId
    numberOfWorkers: numberOfWorkers
    maximumElasticWorkerCount: 20
    zoneRedundant: false
  }
  sku: {
    tier: sku
    name: skuCode
  }
  dependsOn: []
}