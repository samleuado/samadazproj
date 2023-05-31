@description('Extensions Kit certificate resource name')
param certificateResourceName string

@description('The id of the certificate keyvault')
param certificateKeyVaultId string

@description('Name of the certificate in the certificate keyvault')
param certificateName string

param u4costId string = ''
param location string

resource certificateName_resource 'Microsoft.Web/certificates@2021-03-01' = {
  name: certificateResourceName
  location: location
  tags: {
    displayName: 'Extensions Kit Certificate'
    U4COSTID: u4costId
  }
  properties: {
    keyVaultId: certificateKeyVaultId
    keyVaultSecretName: certificateName
    password: ''
  } 
}
