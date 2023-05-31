@metadata({
  desciption: 'Event Grid Topic name'
})
param topicName string
param isPrimaryEnvironment bool
param u4costId string = ''
param location string

targetScope = 'resourceGroup'

resource topicName_resource 'Microsoft.EventGrid/topics@2021-12-01' = if(isPrimaryEnvironment) {
  name: topicName
  location: location
  tags: {
    U4COSTID: u4costId
  }
  properties: {
    inputSchema: 'CloudEventSchemaV1_0'
  }
}
