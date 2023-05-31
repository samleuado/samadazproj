param keyVaultName string
param location string
param idsKeyVaultName string
param servicePrincipalID string
param u4costId string = ''

targetScope = 'resourceGroup'

var tenantId = subscription().tenantId

resource keyVaultName_resource 'Microsoft.KeyVault/vaults@2016-10-01' = if (keyVaultName != idsKeyVaultName) {
  name: keyVaultName
  location: location
  tags: {
    U4COSTID: u4costId
  }
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    enabledForDeployment: true
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: servicePrincipalID
        permissions: {
          keys: []
          secrets: [
            'get'
            'list'
            'set'
          ]
        }
      }
    ]
    createMode: 'recover'
  }
}
