param location string

@description('API Management resource name')
param apiManagementName string
param ekInternalClientId string

@secure()
param ekInternalClientSecret string
param ekOwnerEmail string
param ekOwnerName string

param idsUri string

@description('Extensions Kit API Uri')
param apiManagementNamedValueExtensionsKitUri string

@description('Extensions Kit Webhook Uri')
param apiManagementNamedValueExtensionsKitWebhookUri string

@description('Extensions Kit Webhook V2 Uri')
param apiManagementNamedValueExtensionsKitWebhookV2Uri string

@description('API Management available pricing tiers are: Consumption, Developer, Basic, Standard, Premium, Isolated')
param apiManagementSkuName string = 'Consumption'

@description('API Management instance count')
param apiManagementSkuCapacity int = 0
param apiManagementNamedValueAADIdentityUri string = 'https://login.microsoftonline.com/common'
param apiManagementNamedValueExtensionsKitApiTimeout string = '10'
param apiManagementNamedValueTemplateTenant string = '{{tenant}}'
param apiManagementNamedValueTemplateTriggerId string = '{{triggerId}}'
param apiManagementWebhookName string = 'Webhook'
param apiManagementWebhookMetadataName string = 'WebhookMetadata'
param apiManagementWebhookVersionSetsName string = 'Webhook'
param apiManagementPolicyName string = 'policy'
param apiManagementWebhookSchemaName string = 'WebhookSchema'
param apiManagementWebhookMetadataSchemaName string = 'WebhookMetadataSchema'
param apiManagementProductsUnlimitedName string = 'unlimited'
param apiManagementProductsStarterName string = 'starter'
param apiManagementProductsDesignName string = 'Design'
param apiManagementWebhookPath string = 'webhook'
param apiManagementWebhookMetadataPath string = 'webhook-metadata'
param apiManagementOperationsGetSchema string = 'GetSchema'
param apiManagementOperationsPostMessage string = 'PostMessage'
param apiManagementOperationsOptionsMessage string = 'OptionsMessage'
param apiManagementOperationsGetMessage string = 'GetMessage'
param apiManagementOperationsPutMessage string = 'PutMessage'
param u4costId string = ''

param enableMTLS bool = false

resource apiManagementName_resource 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apiManagementName
  location: location
  sku: {
    name: apiManagementSkuName
    capacity: apiManagementSkuCapacity
  }
  tags: {
    U4COSTID: u4costId
  }
  properties: {
    publisherEmail: ekOwnerEmail
    publisherName: ekOwnerName
    notificationSenderEmail: 'apimgmt-noreply@mail.windowsazure.com'
    hostnameConfigurations: []
    additionalLocations: null
    virtualNetworkConfiguration: null
    virtualNetworkType: 'None'
    certificates: null
    enableClientCertificate: enableMTLS
  }
  dependsOn: []
}

resource apiManagementName_AADIdentityUri 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apiManagementName_resource
  name: 'AADIdentityUri'
  properties: {
    displayName: 'AADIdentityUri'
    value: apiManagementNamedValueAADIdentityUri
    secret: false
  }
}

resource apiManagementName_ExtensionsKitApiTimeout 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apiManagementName_resource
  name: 'ExtensionsKitApiTimeout'
  properties: {
    displayName: 'ExtensionsKitApiTimeout'
    value: apiManagementNamedValueExtensionsKitApiTimeout
    secret: false
  }
}

resource apiManagementName_ExtensionsKitUri 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apiManagementName_resource
  name: 'ExtensionsKitUri'
  properties: {
    displayName: 'ExtensionsKitUri'
    value: apiManagementNamedValueExtensionsKitUri
    secret: false
  }
}

resource apiManagementName_ExtensionsKitWebhookUri 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apiManagementName_resource
  name: 'ExtensionsKitWebhookUri'
  properties: {
    displayName: 'ExtensionsKitWebhookUri'
    value: apiManagementNamedValueExtensionsKitWebhookUri
    secret: false
  }
}

resource apiManagementName_ExtensionsKitWebhookV2Uri 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apiManagementName_resource
  name: 'ExtensionsKitWebhookV2Uri'
  properties: {
    displayName: 'ExtensionsKitWebhookV2Uri'
    value: apiManagementNamedValueExtensionsKitWebhookV2Uri
    secret: false
  }
}

resource apiManagementName_IdentityServicesUri 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apiManagementName_resource
  name: 'IdentityServicesUri'
  properties: {
    displayName: 'IdentityServicesUri'
    value: idsUri
    secret: false
  }
}

resource apiManagementName_InternalClientId 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apiManagementName_resource
  name: 'InternalClientId'
  properties: {
    displayName: 'InternalClientId'
    value: ekInternalClientId
    secret: false
  }
}

resource apiManagementName_InternalClientSecret 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apiManagementName_resource
  name: 'InternalClientSecret'
  properties: {
    displayName: 'InternalClientSecret'
    value: ekInternalClientSecret
    secret: false
  }
}

resource apiManagementName_Template_Tenant 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apiManagementName_resource
  name: 'Template-Tenant'
  properties: {
    displayName: 'Template-Tenant'
    value: apiManagementNamedValueTemplateTenant
    secret: false
  }
}

resource apiManagementName_Template_TriggerId 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apiManagementName_resource
  name: 'Template-TriggerId'
  properties: {
    displayName: 'Template-TriggerId'
    value: apiManagementNamedValueTemplateTriggerId
    secret: false
  }
}

resource apiManagementName_apiManagementWebhookVersionSetsName 'Microsoft.ApiManagement/service/apiVersionSets@2021-08-01' = {
  parent: apiManagementName_resource
  name: apiManagementWebhookVersionSetsName
  properties: {
    displayName: apiManagementWebhookVersionSetsName
    description: null
    versioningScheme: 'Segment'
    versionQueryName: null
    versionHeaderName: null
  }
}

resource apiManagementName_apiManagementWebhookName 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: apiManagementName_resource
  name: apiManagementWebhookName
  properties: {
    displayName: 'Unit4 Extensions Kit ${apiManagementWebhookName}'
    apiRevision: '1'
    description: 'Unit4 Extensions Kit ${apiManagementWebhookName}'
    serviceUrl: apiManagementNamedValueExtensionsKitWebhookUri
    path: apiManagementWebhookPath
    protocols: [
      'https'
    ]
    authenticationSettings: null
    subscriptionKeyParameterNames: null
    apiVersion: 'v1'
    apiVersionSetId: apiManagementName_apiManagementWebhookVersionSetsName.id
  }
}

resource apiManagementName_apiManagementWebhookMetadataName 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: apiManagementName_resource
  name: apiManagementWebhookMetadataName
  properties: {
    displayName: 'Unit4 Extensions Kit ${apiManagementWebhookMetadataName}'
    apiRevision: '1'
    description: 'Unit4 Extensions Kit ${apiManagementWebhookMetadataName}'
    serviceUrl: apiManagementNamedValueExtensionsKitWebhookUri
    path: apiManagementWebhookMetadataPath
    protocols: [
      'https'
    ]
    authenticationSettings: null
    subscriptionKeyParameterNames: null
    apiVersion: 'v1'
    apiVersionSetId: apiManagementName_apiManagementWebhookVersionSetsName.id
  }
}

resource apiManagementName_apiManagementWebhookName_v2 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: apiManagementName_resource
  name: '${apiManagementWebhookName}v2'
  properties: {
    displayName: 'Unit4 Extensions Kit ${apiManagementWebhookName}'
    apiRevision: '1'
    description: 'Unit4 Extensions Kit ${apiManagementWebhookName}'
    serviceUrl: apiManagementNamedValueExtensionsKitWebhookV2Uri
    path: apiManagementWebhookPath
    protocols: [
      'https'
    ]
    authenticationSettings: null
    subscriptionKeyParameterNames: null
    apiVersion: 'v2'
    apiVersionSetId: apiManagementName_apiManagementWebhookVersionSetsName.id
  }
}

resource apiManagementName_apiManagementWebhookMetadataName_v2 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: apiManagementName_resource
  name: '${apiManagementWebhookMetadataName}v2'
  properties: {
    displayName: 'Unit4 Extensions Kit ${apiManagementWebhookMetadataName}'
    apiRevision: '1'
    description: 'Unit4 Extensions Kit ${apiManagementWebhookMetadataName}'
    serviceUrl: apiManagementNamedValueExtensionsKitWebhookV2Uri
    path: apiManagementWebhookMetadataPath
    protocols: [
      'https'
    ]
    authenticationSettings: null
    subscriptionKeyParameterNames: null
    apiVersion: 'v2'
    apiVersionSetId: apiManagementName_apiManagementWebhookVersionSetsName.id
  }
}

resource apiManagementName_apiManagementProductsStarterName 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  parent: apiManagementName_resource
  name: apiManagementProductsStarterName
  properties: {
    displayName: apiManagementProductsStarterName
    description: 'Subscribers will be able to run 5 calls/minute up to a maximum of 100 calls/week.'
    terms: ''
    subscriptionRequired: true
    approvalRequired: false
    subscriptionsLimit: 1
    state: 'published'
  }
}

resource apiManagementName_apiManagementProductsStarterName_apiManagementWebhookName 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  parent: apiManagementName_apiManagementProductsStarterName
  name: apiManagementWebhookName
  dependsOn: [
    apiManagementName_apiManagementWebhookName
  ]
}

resource apiManagementName_apiManagementProductsStarterName_apiManagementWebhookMetadataName 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  parent: apiManagementName_apiManagementProductsStarterName
  name: apiManagementWebhookMetadataName
  dependsOn: [
    apiManagementName_apiManagementWebhookMetadataName
  ]
}

resource apiManagementName_apiManagementProductsStarterName_apiManagementWebhookName_v2 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  parent: apiManagementName_apiManagementProductsStarterName
  name: '${apiManagementWebhookName}v2'
  dependsOn: [
    apiManagementName_apiManagementWebhookName_v2
  ]
}

resource apiManagementName_apiManagementProductsStarterName_apiManagementWebhookMetadataName_v2 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  parent: apiManagementName_apiManagementProductsStarterName
  name: '${apiManagementWebhookMetadataName}v2'
  dependsOn: [
    apiManagementName_apiManagementWebhookName_v2
  ]
}

resource apiManagementName_apiManagementProductsDesignName 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  parent: apiManagementName_resource
  name: apiManagementProductsDesignName
  properties: {
    displayName: apiManagementProductsDesignName
    description: 'Exposes the Webhook Metadata to be used from LogicApps and other third party products'
    terms: null
    subscriptionRequired: false
    approvalRequired: null
    subscriptionsLimit: null
    state: 'published'
  }
}

resource apiManagementName_apiManagementProductsDesignName_apiManagementWebhookName 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  parent: apiManagementName_apiManagementProductsDesignName
  name: apiManagementWebhookName
  dependsOn: [
    apiManagementName_apiManagementWebhookName
  ]
}

resource apiManagementName_apiManagementProductsDesignName_apiManagementWebhookMetadataName 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  parent: apiManagementName_apiManagementProductsDesignName
  name: apiManagementWebhookMetadataName
  dependsOn: [
    apiManagementName_apiManagementWebhookMetadataName
  ]
}

resource apiManagementName_apiManagementProductsDesignName_apiManagementWebhookName_v2 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  parent: apiManagementName_apiManagementProductsDesignName
  name: '${apiManagementWebhookName}v2'
  dependsOn: [
    apiManagementName_apiManagementWebhookName_v2
  ]
}

resource apiManagementName_apiManagementProductsDesignName_apiManagementWebhookMetadataName_v2 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  parent: apiManagementName_apiManagementProductsDesignName
  name: '${apiManagementWebhookMetadataName}v2'
  dependsOn: [
    apiManagementName_apiManagementWebhookMetadataName_v2
  ]
}

resource apiManagementName_apiManagementProductsUnlimitedName 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  parent: apiManagementName_resource
  name: apiManagementProductsUnlimitedName
  properties: {
    displayName: apiManagementProductsUnlimitedName
    description: 'Subscribers have completely ${apiManagementProductsUnlimitedName} access to the API. Administrator approval is required.'
    terms: null
    subscriptionRequired: true
    approvalRequired: true
    subscriptionsLimit: 1
    state: 'published'
  }
}

resource apiManagementName_apiManagementProductsUnlimitedName_apiManagementWebhookName 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  parent: apiManagementName_apiManagementProductsUnlimitedName
  name: apiManagementWebhookName
  dependsOn: [
    apiManagementName_apiManagementWebhookName
  ]
}

resource apiManagementName_apiManagementProductsUnlimitedName_apiManagementWebhookMetadataName 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  parent: apiManagementName_apiManagementProductsUnlimitedName
  name: apiManagementWebhookMetadataName
  dependsOn: [
    apiManagementName_apiManagementWebhookMetadataName
  ]
}

resource apiManagementName_apiManagementProductsUnlimitedName_apiManagementWebhookName_v2 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  parent: apiManagementName_apiManagementProductsUnlimitedName
  name: '${apiManagementWebhookName}v2'
  dependsOn: [
    apiManagementName_apiManagementWebhookName_v2
  ]
}

resource apiManagementName_apiManagementProductsUnlimitedName_apiManagementWebhookMetadataName_v2 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  parent: apiManagementName_apiManagementProductsUnlimitedName
  name: '${apiManagementWebhookMetadataName}v2'
  dependsOn: [
    apiManagementName_apiManagementWebhookMetadataName_v2
  ]
}

resource apiManagementName_apiManagementWebhookMetadataName_apiManagementOperationsGetSchema 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  parent: apiManagementName_apiManagementWebhookMetadataName
  name: apiManagementOperationsGetSchema
  properties: {
    displayName: 'Webhook_${apiManagementOperationsGetSchema}'
    method: 'GET'
    urlTemplate: '/{triggerId}?sig={sig}'
    templateParameters: [
      {
        name: 'triggerId'
        type: 'string'
        required: true
        values: []
      }
      {
        name: 'sig'
        type: 'string'
        required: true
        values: []
      }
    ]
    description: null
    responses: [
      {
        statusCode: 200
        description: 'OK'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'Object'
          }
        ]
        headers: []
      }
      {
        statusCode: 400
        description: 'BadRequest'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}SwaggerGet400ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}SwaggerGet400TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}SwaggerGet400ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}SwaggerGet400TextXmlResponse'
          }
        ]
        headers: []
      }
      {
        statusCode: 403
        description: 'Forbidden'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}SwaggerGet403ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}SwaggerGet403TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}SwaggerGet403ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}SwaggerGet403TextXmlResponse'
          }
        ]
        headers: []
      }
      {
        statusCode: 404
        description: 'NotFound'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}SwaggerGet404ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}SwaggerGet404TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}SwaggerGet404ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}SwaggerGet404TextXmlResponse'
          }
        ]
        headers: []
      }
    ]
    policies: null
  }
  dependsOn: [
    apiManagementName_apiManagementWebhookMetadataName_apiManagementWebhookMetadataSchemaName
  ]
}

resource apiManagementName_apiManagementWebhookMetadataName_apiManagementPolicyName 'Microsoft.ApiManagement/service/apis/policies@2021-08-01' = {
  parent: apiManagementName_apiManagementWebhookMetadataName
  name: apiManagementPolicyName
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <cors>\r\n      <allowed-origins>\r\n        <origin>*</origin>\r\n        <!-- allow any -->\r\n      </allowed-origins>\r\n      <allowed-methods>\r\n        <!-- allow any -->\r\n        <method>GET</method>\r\n        <method>POST</method>\r\n        <method>PATCH</method>\r\n        <method>DELETE</method>\r\n      </allowed-methods>\r\n      <allowed-headers>\r\n        <!-- allow any -->\r\n        <header>*</header>\r\n      </allowed-headers>\r\n    </cors>\r\n    <set-backend-service base-url="{{ExtensionsKitWebhookUri}}/api/v1/triggers/http-webhook" />\r\n    <rewrite-uri template="{triggerId}/swagger?sig={sig}" />\r\n    <base />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
  dependsOn: [
    apiManagementName_ExtensionsKitWebhookUri
  ]
}

resource apiManagementName_apiManagementWebhookMetadataName_apiManagementWebhookMetadataSchemaName 'Microsoft.ApiManagement/service/apis/schemas@2021-08-01' = {
  parent: apiManagementName_apiManagementWebhookMetadataName
  name: apiManagementWebhookMetadataSchemaName
  properties: {
    contentType: 'application/vnd.ms-azure-apim.swagger.definitions+json'
    document: {}
  }
}

resource apiManagementName_apiManagementWebhookMetadataName_v2_apiManagementOperationsGetSchema 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  parent: apiManagementName_apiManagementWebhookMetadataName_v2
  name: apiManagementOperationsGetSchema
  properties: {
    displayName: 'Webhook_${apiManagementOperationsGetSchema}v2'
    method: 'GET'
    urlTemplate: '/{triggerId}?sig={sig}'
    templateParameters: [
      {
        name: 'triggerId'
        type: 'string'
        required: true
        values: []
      }
      {
        name: 'sig'
        type: 'string'
        required: true
        values: []
      }
    ]
    description: null
    responses: [
      {
        statusCode: 200
        description: 'OK'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'Object'
          }
        ]
        headers: []
      }
      {
        statusCode: 400
        description: 'BadRequest'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}SwaggerGet400ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}SwaggerGet400TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}SwaggerGet400ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}SwaggerGet400TextXmlResponse'
          }
        ]
        headers: []
      }
      {
        statusCode: 403
        description: 'Forbidden'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}SwaggerGet403ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}SwaggerGet403TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}SwaggerGet403ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}SwaggerGet403TextXmlResponse'
          }
        ]
        headers: []
      }
      {
        statusCode: 404
        description: 'NotFound'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}SwaggerGet404ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}SwaggerGet404TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}SwaggerGet404ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookMetadataSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}SwaggerGet404TextXmlResponse'
          }
        ]
        headers: []
      }
    ]
    policies: null
  }
  dependsOn: [
    apiManagementName_apiManagementWebhookMetadataName_v2_apiManagementWebhookMetadataSchemaName
  ]
}

resource apiManagementName_apiManagementWebhookMetadataName_v2_apiManagementPolicyName 'Microsoft.ApiManagement/service/apis/policies@2021-08-01' = {
  parent: apiManagementName_apiManagementWebhookMetadataName_v2
  name: apiManagementPolicyName
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <cors>\r\n      <allowed-origins>\r\n        <origin>*</origin>\r\n        <!-- allow any -->\r\n      </allowed-origins>\r\n      <allowed-methods>\r\n        <!-- allow any -->\r\n        <method>GET</method>\r\n        <method>POST</method>\r\n        <method>PATCH</method>\r\n        <method>DELETE</method>\r\n      </allowed-methods>\r\n      <allowed-headers>\r\n        <!-- allow any -->\r\n        <header>*</header>\r\n      </allowed-headers>\r\n    </cors>\r\n    <set-backend-service base-url="{{ExtensionsKitWebhookV2Uri}}/api/v2/triggers/http-webhook" />\r\n    <rewrite-uri template="{triggerId}/swagger?sig={sig}" />\r\n    <base />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
  dependsOn: [
    apiManagementName_ExtensionsKitWebhookV2Uri
  ]
}

resource apiManagementName_apiManagementWebhookMetadataName_v2_apiManagementWebhookMetadataSchemaName 'Microsoft.ApiManagement/service/apis/schemas@2021-08-01' = {
  parent: apiManagementName_apiManagementWebhookMetadataName_v2
  name: apiManagementWebhookMetadataSchemaName
  properties: {
    contentType: 'application/vnd.ms-azure-apim.swagger.definitions+json'
    document: {}
  }
}

resource apiManagementName_apiManagementWebhookName_apiManagementOperationsPostMessage 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  parent: apiManagementName_apiManagementWebhookName
  name: apiManagementOperationsPostMessage
  properties: {
    displayName: 'Webhook_${apiManagementOperationsPostMessage}'
    method: 'POST'
    urlTemplate: '/{triggerId}?sig={sig}'
    templateParameters: [
      {
        name: 'triggerId'
        type: 'string'
        required: true
        values: []
      }
      {
        name: 'sig'
        type: 'string'
        required: true
        values: []
      }
    ]
    description: null
    request: {
      queryParameters: []
      headers: []
      representations: [
        {
          contentType: 'application/json'
          schemaId: apiManagementWebhookSchemaName
          typeName: 'Object'
        }
        {
          contentType: 'text/json'
          schemaId: apiManagementWebhookSchemaName
          typeName: 'Object'
        }
        {
          contentType: 'application/x-www-form-urlencoded'
        }
      ]
    }
    responses: [
      {
        statusCode: 204
        description: 'NoContent'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
        ]
        headers: []
      }
      {
        statusCode: 400
        description: 'BadRequest'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}Post400ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}Post400TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}Post400ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}Post400TextXmlResponse'
          }
        ]
        headers: []
      }
      {
        statusCode: 403
        description: 'Forbidden'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}Post403ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}Post403TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}Post403ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}Post403TextXmlResponse'
          }
        ]
        headers: []
      }
      {
        statusCode: 404
        description: 'NotFound'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}Post404ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}Post404TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}Post404ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV1TriggersHttp-webhook{triggerId}Post404TextXmlResponse'
          }
        ]
        headers: []
      }
    ]
    policies: null
  }
  dependsOn: [
    apiManagementName_apiManagementWebhookName_apiManagementWebhookSchemaName
  ]
}

resource apiManagementName_apiManagementWebhookName_apiManagementPolicyName 'Microsoft.ApiManagement/service/apis/policies@2021-08-01' = {
  parent: apiManagementName_apiManagementWebhookName
  name: apiManagementPolicyName
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n    <set-backend-service base-url="{{ExtensionsKitWebhookUri}}/api/v1/triggers/http-webhook" />\r\n    <!--- Get IDS Token -->\r\n    <send-request ignore-error="true" timeout="{{ExtensionsKitApiTimeout}}" response-variable-name="idsResponse" mode="new">\r\n      <set-url>{{IdentityServicesUri}}/connect/token</set-url>\r\n      <set-method>POST</set-method>\r\n      <set-header name="Content-Type" exists-action="override">\r\n        <value>application/x-www-form-urlencoded</value>\r\n      </set-header>\r\n      <set-body>@{\r\n                        return "client_id={{InternalClientId}}&amp;scope=u4ek-public-api&amp;client_secret={{InternalClientSecret}}&amp;grant_type=client_credentials";\r\n                    }</set-body>\r\n    </send-request>\r\n    <!--  Handle Errors, Timeouts while getting access token-->\r\n    <choose>\r\n      <!--  in case of timeouts, the value of idsResponse is null -->\r\n      <when condition="@(((IResponse)context.Variables[&quot;idsResponse&quot;]) == null)">\r\n        <return-response>\r\n          <set-status code="429" reason="Too many request" />\r\n          <set-header name="Retry-After" exists-action="override">\r\n            <value>30</value>\r\n          </set-header>\r\n        </return-response>\r\n      </when>\r\n      <!--  Forward errors while getting access token -->\r\n      <when condition="@(((IResponse)context.Variables[&quot;idsResponse&quot;]).StatusCode != 200)">\r\n        <return-response response-variable-name="idsResponse" />\r\n      </when>\r\n    </choose>\r\n    <set-variable name="idsResponseObject" value="@( ((IResponse)context.Variables[&quot;idsResponse&quot;]).Body.As&lt;JObject&gt;())" />\r\n    <set-variable name="idsAccessToken" value="@( ((JObject)context.Variables[&quot;idsResponseObject&quot;])[&quot;access_token&quot;].ToString())" />\r\n    <set-variable name="idsTokenExpiresIn" value="@( ((JObject)context.Variables[&quot;idsResponseObject&quot;])[&quot;expires_in&quot;]?.ToString() ?? &quot;3600&quot;)" />\r\n    <!-- Get TriggerDefinition from ExtensionsKit API -->\r\n    <send-request ignore-error="true" timeout="{{ExtensionsKitApiTimeout}}" response-variable-name="triggerResponse" mode="new">\r\n      <set-url>@("{{ExtensionsKitUri}}/api/v2/triggers/"+ context.Request.MatchedParameters["triggerId"])</set-url>\r\n      <set-method>GET</set-method>\r\n      <set-header name="Authorization" exists-action="override">\r\n        <value>@("Bearer " + (string)context.Variables["idsAccessToken"])</value>\r\n      </set-header>\r\n    </send-request>\r\n    <!--  Handle Errors, Timeouts while reading Trigger -->\r\n    <choose>\r\n      <!--  in case of timeouts, the value of triggerResponse is null -->\r\n      <when condition="@(((IResponse)context.Variables[&quot;triggerResponse&quot;]) == null)">\r\n        <return-response response-variable-name="triggerResponse">\r\n          <set-status code="429" reason="Too many request" />\r\n          <set-header name="Retry-After" exists-action="override">\r\n            <value>30</value>\r\n          </set-header>\r\n        </return-response>\r\n      </when>\r\n      <!--  Forward errors while getting trigger -->\r\n      <when condition="@(((IResponse)context.Variables[&quot;triggerResponse&quot;]).StatusCode != 200)">\r\n        <return-response response-variable-name="triggerResponse" />\r\n      </when>\r\n      <otherwise />\r\n    </choose>\r\n    <set-variable name="triggerResponseObject" value="@( ((IResponse)context.Variables[&quot;triggerResponse&quot;]).Body.As&lt;JObject&gt;())" />\r\n    <set-variable name="triggerConfigObject" value="@( ((JObject)context.Variables[&quot;triggerResponseObject&quot;])[&quot;Config&quot;] )" />\r\n    <set-variable name="triggerConfig-AuthenticationType" value="@( ((JObject)context.Variables[&quot;triggerConfigObject&quot;])[&quot;AuthenticationType&quot;]?.ToString() ?? &quot;&quot; )" />\r\n    <choose>\r\n      <when condition="@(((string)context.Variables[&quot;triggerConfig-AuthenticationType&quot;]).Equals(&quot;Basic&quot;, StringComparison.InvariantCultureIgnoreCase))">\r\n        <!--  Flow requests  Basic  Authorization -->\r\n        <set-variable name="triggerConfig-Authentication-user" value="@( ((JObject)context.Variables[&quot;triggerConfigObject&quot;])[&quot;UserName&quot;]?.ToString() ?? &quot;&quot; )" />\r\n        <set-variable name="triggerConfig-Authentication-password" value="@( ((JObject)context.Variables[&quot;triggerConfigObject&quot;])[&quot;Password&quot;]?.ToString() ?? &quot;&quot; )" />\r\n        <set-variable name="triggerConfig-Authentication-issuer" value="@( ((JObject)context.Variables[&quot;triggerConfigObject&quot;])[&quot;Issuer&quot;]?.ToString() ?? &quot;&quot; )" />\r\n        <set-variable name="triggerConfig-Authentication-basic" value="@(&quot;Basic &quot; + Convert.ToBase64String(Encoding.ASCII.GetBytes(context.Variables[&quot;triggerConfig-Authentication-user&quot;] + &quot;:&quot; + context.Variables[&quot;triggerConfig-Authentication-password&quot;])) )" />\r\n        <!--  Calculate authorization header value -->\r\n        <check-header name="Authorization" failed-check-httpcode="401" failed-check-error-message="Not authorized" ignore-case="false">\r\n          <value>@((string)context.Variables["triggerConfig-Authentication-basic"])</value>\r\n        </check-header>\r\n      </when>\r\n      <when condition="@(((string)context.Variables[&quot;triggerConfig-AuthenticationType&quot;]).Equals(&quot;U4IDS&quot;, StringComparison.InvariantCultureIgnoreCase))">\r\n        <validate-jwt header-name="Authorization">\r\n          <openid-config url="{{IdentityServicesUri}}/.well-known/openid-configuration" />\r\n        </validate-jwt>\r\n        <set-variable name="jwtToken" value="@( context.Request.Headers[&quot;Authorization&quot;]?.First()?.Substring(&quot;Bearer &quot;.Length)?.AsJwt() )" />\r\n      </when>\r\n      <when condition="@(((string)context.Variables[&quot;triggerConfig-AuthenticationType&quot;]).Equals(&quot;AAD&quot;, StringComparison.InvariantCultureIgnoreCase))">\r\n        <trace source="Trace">"AAD {{AADIdentityUri}}"</trace>\r\n        <validate-jwt header-name="Authorization">\r\n          <openid-config url="{{AADIdentityUri}}/.well-known/openid-configuration" />\r\n        </validate-jwt>\r\n        <set-variable name="jwtToken" value="@( context.Request.Headers[&quot;Authorization&quot;]?.First()?.Substring(&quot;Bearer &quot;.Length)?.AsJwt() )" />\r\n      </when>\r\n    </choose>\r\n    <choose>\r\n      <when condition="@(context.Variables.ContainsKey(&quot;jwtToken&quot;))">\r\n        <set-variable name="claimsFound" value="@{                                 &#xA;                    Jwt jwtToken = ((Jwt)context.Variables[&quot;jwtToken&quot;]);&#xA;                    JObject triggerConfigObject = (JObject)context.Variables[&quot;triggerConfigObject&quot;];&#xA;                    if (triggerConfigObject[&quot;ClaimRules&quot;] != null &amp;&amp; triggerConfigObject[&quot;ClaimRules&quot;].Type == JTokenType.Object) {   &#xA;                        foreach(var rule in ((JObject)triggerConfigObject[&quot;ClaimRules&quot;]).Properties()) &#xA;                        {                        &#xA;                            var value = rule.Last()?.ToString();&#xA;                            string[] claims;&#xA;                            if (!jwtToken.Claims.TryGetValue(rule.Name, out claims)) {&#xA;                                return false;    &#xA;                            }&#xA;                            &#xA;                            switch (value)&#xA;                            {&#xA;                                case &quot;{{Template-Tenant}}&quot;:&#xA;                                    value = triggerConfigObject[&quot;TenantId&quot;].ToString();&#xA;                                    break;&#xA;                                case &quot;{{Template-TriggerId}}&quot;:&#xA;                                    value = triggerConfigObject[&quot;TriggerId&quot;].ToString();&#xA;                                    break;&#xA;                            }&#xA;                            if (!claims.Contains(value)) {&#xA;                                return false;&#xA;                            }&#xA;                        }&#xA;                    }&#xA;                    return true;&#xA;                }" />\r\n        <choose>\r\n          <when condition="@( ((bool)context.Variables[&quot;claimsFound&quot;]) != true)">\r\n            <return-response>\r\n              <set-status code="401" reason="Requested claims not present" />\r\n            </return-response>\r\n          </when>\r\n        </choose>\r\n      </when>\r\n    </choose>\r\n    <!--  Don\'t expose APIM subscription key to the backend. -->\r\n    <set-header name="Ocp-Apim-Subscription-Key" exists-action="delete" />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
  dependsOn: [
    apiManagementName_IdentityServicesUri
    apiManagementName_ExtensionsKitWebhookUri
  ]
}

resource apiManagementName_apiManagementWebhookName_apiManagementWebhookSchemaName 'Microsoft.ApiManagement/service/apis/schemas@2021-08-01' = {
  parent: apiManagementName_apiManagementWebhookName
  name: apiManagementWebhookSchemaName
  properties: {
    contentType: 'application/vnd.ms-azure-apim.swagger.definitions+json'
    document: {}
  }
}

resource apiManagementName_apiManagementWebhookName_v2_apiManagementOperationsOptionsMessage 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  parent: apiManagementName_apiManagementWebhookName_v2
  name: apiManagementOperationsOptionsMessage
  properties: {
    displayName: 'Webhook_${apiManagementOperationsOptionsMessage}'
    method: 'OPTIONS'
    urlTemplate: '/{triggerId}?sig={sig}'
    templateParameters: [
      {
        name: 'triggerId'
        type: 'string'
        required: true
        values: []
      }
      {
        name: 'sig'
        type: 'string'
        required: true
        values: []
      }
    ]
    description: null
    request: {
      queryParameters: []
      headers: []
      representations: [
        {
          contentType: 'application/json'
          schemaId: apiManagementWebhookSchemaName
          typeName: 'Object'
        }
        {
          contentType: 'text/json'
          schemaId: apiManagementWebhookSchemaName
          typeName: 'Object'
        }
        {
          contentType: 'application/x-www-form-urlencoded'
        }
      ]
    }
    responses: [
      {
        statusCode: 204
        description: 'NoContent'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
        ]
        headers: []
      }
      {
        statusCode: 400
        description: 'BadRequest'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Options400ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Options400TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Options400ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Options400TextXmlResponse'
          }
        ]
        headers: []
      }
      {
        statusCode: 403
        description: 'Forbidden'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Options403ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Options403TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Options403ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Options403TextXmlResponse'
          }
        ]
        headers: []
      }
      {
        statusCode: 404
        description: 'NotFound'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Options404ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Options404TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Options404ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Options404TextXmlResponse'
          }
        ]
        headers: []
      }
    ]
    policies: null
  }
  dependsOn: [
    apiManagementName_apiManagementWebhookName_v2_apiManagementWebhookSchemaName
  ]
}

resource apiManagementName_apiManagementWebhookName_v2_apiManagementOperationsGetMessage 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  parent: apiManagementName_apiManagementWebhookName_v2
  name: apiManagementOperationsGetMessage
  properties: {
    displayName: 'Webhook_${apiManagementOperationsGetMessage}'
    method: 'GET'
    urlTemplate: '/{triggerId}?sig={sig}'
    templateParameters: [
      {
        name: 'triggerId'
        type: 'string'
        required: true
        values: []
      }
      {
        name: 'sig'
        type: 'string'
        required: true
        values: []
      }
    ]
    description: null
    request: {
      queryParameters: []
      headers: []
      representations: [
        {
          contentType: 'application/json'
          schemaId: apiManagementWebhookSchemaName
          typeName: 'Object'
        }
        {
          contentType: 'text/json'
          schemaId: apiManagementWebhookSchemaName
          typeName: 'Object'
        }
        {
          contentType: 'application/x-www-form-urlencoded'
        }
      ]
    }
    responses: [
      {
        statusCode: 204
        description: 'NoContent'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
        ]
        headers: []
      }
      {
        statusCode: 400
        description: 'BadRequest'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Get400ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Get400TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Get400ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Get400TextXmlResponse'
          }
        ]
        headers: []
      }
      {
        statusCode: 403
        description: 'Forbidden'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Get403ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Get403TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Get403ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Get403TextXmlResponse'
          }
        ]
        headers: []
      }
      {
        statusCode: 404
        description: 'NotFound'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Get404ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Get404TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Get404ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Get404TextXmlResponse'
          }
        ]
        headers: []
      }
    ]
    policies: null
  }
  dependsOn: [
    apiManagementName_apiManagementWebhookName_v2_apiManagementWebhookSchemaName
  ]
}

resource apiManagementName_apiManagementWebhookName_v2_apiManagementOperationsPutMessage 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  parent: apiManagementName_apiManagementWebhookName_v2
  name: apiManagementOperationsPutMessage
  properties: {
    displayName: 'Webhook_${apiManagementOperationsPutMessage}'
    method: 'PUT'
    urlTemplate: '/{triggerId}?sig={sig}'
    templateParameters: [
      {
        name: 'triggerId'
        type: 'string'
        required: true
        values: []
      }
      {
        name: 'sig'
        type: 'string'
        required: true
        values: []
      }
    ]
    description: null
    request: {
      queryParameters: []
      headers: []
      representations: [
        {
          contentType: 'application/json'
          schemaId: apiManagementWebhookSchemaName
          typeName: 'Object'
        }
        {
          contentType: 'text/json'
          schemaId: apiManagementWebhookSchemaName
          typeName: 'Object'
        }
        {
          contentType: 'application/x-www-form-urlencoded'
        }
      ]
    }
    responses: [
      {
        statusCode: 204
        description: 'NoContent'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
        ]
        headers: []
      }
      {
        statusCode: 400
        description: 'BadRequest'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Put400ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Put400TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Put400ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Put400TextXmlResponse'
          }
        ]
        headers: []
      }
      {
        statusCode: 403
        description: 'Forbidden'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Put403ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Put403TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Put403ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Put403TextXmlResponse'
          }
        ]
        headers: []
      }
      {
        statusCode: 404
        description: 'NotFound'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Put404ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Put404TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Put404ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Put404TextXmlResponse'
          }
        ]
        headers: []
      }
    ]
    policies: null
  }
  dependsOn: [
    apiManagementName_apiManagementWebhookName_v2_apiManagementWebhookSchemaName
  ]
}

resource apiManagementName_apiManagementWebhookName_v2_apiManagementOperationsPostMessage 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  parent: apiManagementName_apiManagementWebhookName_v2
  name: apiManagementOperationsPostMessage
  properties: {
    displayName: 'Webhook_${apiManagementOperationsPostMessage}'
    method: 'POST'
    urlTemplate: '/{triggerId}?sig={sig}'
    templateParameters: [
      {
        name: 'triggerId'
        type: 'string'
        required: true
        values: []
      }
      {
        name: 'sig'
        type: 'string'
        required: true
        values: []
      }
    ]
    description: null
    request: {
      queryParameters: []
      headers: []
      representations: [
        {
          contentType: 'application/json'
          schemaId: apiManagementWebhookSchemaName
          typeName: 'Object'
        }
        {
          contentType: 'text/json'
          schemaId: apiManagementWebhookSchemaName
          typeName: 'Object'
        }
        {
          contentType: 'application/x-www-form-urlencoded'
        }
      ]
    }
    responses: [
      {
        statusCode: 204
        description: 'NoContent'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'Object'
          }
        ]
        headers: []
      }
      {
        statusCode: 400
        description: 'BadRequest'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Post400ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Post400TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Post400ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Post400TextXmlResponse'
          }
        ]
        headers: []
      }
      {
        statusCode: 403
        description: 'Forbidden'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Post403ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Post403TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Post403ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Post403TextXmlResponse'
          }
        ]
        headers: []
      }
      {
        statusCode: 404
        description: 'NotFound'
        representations: [
          {
            contentType: 'application/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Post404ApplicationJsonResponse'
          }
          {
            contentType: 'text/json'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Post404TextJsonResponse'
          }
          {
            contentType: 'application/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Post404ApplicationXmlResponse'
          }
          {
            contentType: 'text/xml'
            schemaId: apiManagementWebhookSchemaName
            typeName: 'ApiV2TriggersHttp-webhook{triggerId}Post404TextXmlResponse'
          }
        ]
        headers: []
      }
    ]
    policies: null
  }
  dependsOn: [
    apiManagementName_apiManagementWebhookName_v2_apiManagementWebhookSchemaName
  ]
}

resource apiManagementName_apiManagementWebhookName_v2_apiManagementPolicyName 'Microsoft.ApiManagement/service/apis/policies@2021-08-01' = {
  parent: apiManagementName_apiManagementWebhookName_v2
  name: apiManagementPolicyName
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n    <set-backend-service base-url="{{ExtensionsKitWebhookV2Uri}}/api/v2/triggers/http-webhook" />\r\n    <!-- Get Token from Ids -->\r\n    <send-request ignore-error="true" timeout="{{ExtensionsKitApiTimeout}}" response-variable-name="idsResponse" mode="new">\r\n      <set-url>{{IdentityServicesUri}}/connect/token</set-url>\r\n      <set-method>POST</set-method>\r\n      <set-header name="Content-Type" exists-action="override">\r\n        <value>application/x-www-form-urlencoded</value>\r\n      </set-header>\r\n      <set-body>@{\r\n                        return "client_id={{InternalClientId}}&amp;scope=u4ek-public-api&amp;client_secret={{InternalClientSecret}}&amp;grant_type=client_credentials";\r\n                    }</set-body>\r\n    </send-request>\r\n    <!--  Handle Errors, Timeouts while getting access token-->\r\n    <choose>\r\n      <!--  in case of timeouts, the value of idsResponse is null -->\r\n      <when condition="@(((IResponse)context.Variables[&quot;idsResponse&quot;]) == null)">\r\n        <return-response>\r\n          <set-status code="429" reason="Too many request" />\r\n          <set-header name="Retry-After" exists-action="override">\r\n            <value>30</value>\r\n          </set-header>\r\n        </return-response>\r\n      </when>\r\n      <!--  Forward errors while getting access token -->\r\n      <when condition="@(((IResponse)context.Variables[&quot;idsResponse&quot;]).StatusCode != 200)">\r\n        <return-response response-variable-name="idsResponse" />\r\n      </when>\r\n    </choose>\r\n    <set-variable name="idsResponseObject" value="@( ((IResponse)context.Variables[&quot;idsResponse&quot;]).Body.As&lt;JObject&gt;())" />\r\n    <set-variable name="idsAccessToken" value="@( ((JObject)context.Variables[&quot;idsResponseObject&quot;])[&quot;access_token&quot;].ToString())" />\r\n    <set-variable name="idsTokenExpiresIn" value="@( ((JObject)context.Variables[&quot;idsResponseObject&quot;])[&quot;expires_in&quot;]?.ToString() ?? &quot;3600&quot;)" />\r\n    <!-- Get TriggerDefinition from ExtensionsKit API -->\r\n    <send-request ignore-error="true" timeout="{{ExtensionsKitApiTimeout}}" response-variable-name="triggerResponse" mode="new">\r\n      <set-url>@("{{ExtensionsKitUri}}/api/v2/triggers/"+ context.Request.MatchedParameters["triggerId"])</set-url>\r\n      <set-method>GET</set-method>\r\n      <set-header name="Authorization" exists-action="override">\r\n        <value>@("Bearer " + (string)context.Variables["idsAccessToken"])</value>\r\n      </set-header>\r\n    </send-request>\r\n    <!--  Handle Errors, Timeouts while reading Trigger -->\r\n    <choose>\r\n      <!--  in case of timeouts, the value of triggerResponse is null -->\r\n      <when condition="@(((IResponse)context.Variables[&quot;triggerResponse&quot;]) == null)">\r\n        <return-response response-variable-name="triggerResponse">\r\n          <set-status code="429" reason="Too many request" />\r\n          <set-header name="Retry-After" exists-action="override">\r\n            <value>30</value>\r\n          </set-header>\r\n        </return-response>\r\n      </when>\r\n      <!--  Forward errors while getting trigger -->\r\n      <when condition="@(((IResponse)context.Variables[&quot;triggerResponse&quot;]).StatusCode != 200)">\r\n        <return-response response-variable-name="triggerResponse" />\r\n      </when>\r\n      <otherwise />\r\n    </choose>\r\n    <set-variable name="triggerResponseObject" value="@( ((IResponse)context.Variables[&quot;triggerResponse&quot;]).Body.As&lt;JObject&gt;())" />\r\n    <set-variable name="triggerConfigObject" value="@( ((JObject)context.Variables[&quot;triggerResponseObject&quot;])[&quot;Config&quot;] )" />\r\n    <set-variable name="triggerConfig-AuthenticationType" value="@( ((JObject)context.Variables[&quot;triggerConfigObject&quot;])[&quot;AuthenticationType&quot;]?.ToString() ?? &quot;&quot; )" />\r\n    <choose>\r\n      <when condition="@(((string)context.Variables[&quot;triggerConfig-AuthenticationType&quot;]).Equals(&quot;Basic&quot;, StringComparison.InvariantCultureIgnoreCase))">\r\n        <!--  Flow requests  Basic  Authorization -->\r\n        <set-variable name="triggerConfig-Authentication-user" value="@( ((JObject)context.Variables[&quot;triggerConfigObject&quot;])[&quot;UserName&quot;]?.ToString() ?? &quot;&quot; )" />\r\n        <set-variable name="triggerConfig-Authentication-password" value="@( ((JObject)context.Variables[&quot;triggerConfigObject&quot;])[&quot;Password&quot;]?.ToString() ?? &quot;&quot; )" />\r\n        <set-variable name="triggerConfig-Authentication-issuer" value="@( ((JObject)context.Variables[&quot;triggerConfigObject&quot;])[&quot;Issuer&quot;]?.ToString() ?? &quot;&quot; )" />\r\n        <set-variable name="triggerConfig-Authentication-basic" value="@(&quot;Basic &quot; + Convert.ToBase64String(Encoding.ASCII.GetBytes(context.Variables[&quot;triggerConfig-Authentication-user&quot;] + &quot;:&quot; + context.Variables[&quot;triggerConfig-Authentication-password&quot;])) )" />\r\n        <!--  Calculate authorization header value -->\r\n        <check-header name="Authorization" failed-check-httpcode="401" failed-check-error-message="Not authorized" ignore-case="false">\r\n          <value>@((string)context.Variables["triggerConfig-Authentication-basic"])</value>\r\n        </check-header>\r\n      </when>\r\n      <when condition="@(((string)context.Variables[&quot;triggerConfig-AuthenticationType&quot;]).Equals(&quot;U4IDS&quot;, StringComparison.InvariantCultureIgnoreCase))">\r\n        <validate-jwt header-name="Authorization">\r\n          <openid-config url="{{IdentityServicesUri}}/.well-known/openid-configuration" />\r\n        </validate-jwt>\r\n        <set-variable name="jwtToken" value="@( context.Request.Headers[&quot;Authorization&quot;]?.First()?.Substring(&quot;Bearer &quot;.Length)?.AsJwt() )" />\r\n      </when>\r\n      <when condition="@(((string)context.Variables[&quot;triggerConfig-AuthenticationType&quot;]).Equals(&quot;AAD&quot;, StringComparison.InvariantCultureIgnoreCase))">\r\n        <trace source="Trace">"AAD {{AADIdentityUri}}"</trace>\r\n        <validate-jwt header-name="Authorization">\r\n          <openid-config url="{{AADIdentityUri}}/.well-known/openid-configuration" />\r\n        </validate-jwt>\r\n        <set-variable name="jwtToken" value="@( context.Request.Headers[&quot;Authorization&quot;]?.First()?.Substring(&quot;Bearer &quot;.Length)?.AsJwt() )" />\r\n      </when>\r\n    </choose>\r\n    <choose>\r\n      <when condition="@(context.Variables.ContainsKey(&quot;jwtToken&quot;))">\r\n        <set-variable name="claimsFound" value="@{                                 &#xA;                    Jwt jwtToken = ((Jwt)context.Variables[&quot;jwtToken&quot;]);&#xA;                    JObject triggerConfigObject = (JObject)context.Variables[&quot;triggerConfigObject&quot;];&#xA;                    if (triggerConfigObject[&quot;ClaimRules&quot;] != null &amp;&amp; triggerConfigObject[&quot;ClaimRules&quot;].Type == JTokenType.Object) {   &#xA;                        foreach(var rule in ((JObject)triggerConfigObject[&quot;ClaimRules&quot;]).Properties()) &#xA;                        {                        &#xA;                            var value = rule.Last()?.ToString();&#xA;                            string[] claims;&#xA;                            if (!jwtToken.Claims.TryGetValue(rule.Name, out claims)) {&#xA;                                return false;    &#xA;                            }&#xA;                            &#xA;                            switch (value)&#xA;                            {&#xA;                                case &quot;{{Template-Tenant}}&quot;:&#xA;                                    value = triggerConfigObject[&quot;TenantId&quot;].ToString();&#xA;                                    break;&#xA;                                case &quot;{{Template-TriggerId}}&quot;:&#xA;                                    value = triggerConfigObject[&quot;TriggerId&quot;].ToString();&#xA;                                    break;&#xA;                            }&#xA;                            if (!claims.Contains(value)) {&#xA;                                return false;&#xA;                            }&#xA;                        }&#xA;                    }&#xA;                    return true;&#xA;                }" />\r\n        <choose>\r\n          <when condition="@( ((bool)context.Variables[&quot;claimsFound&quot;]) != true)">\r\n            <return-response>\r\n              <set-status code="401" reason="Requested claims not present" />\r\n            </return-response>\r\n          </when>\r\n        </choose>\r\n      </when>\r\n    </choose>\r\n    <!-- Incoming certificate verificaction -->\r\n    <set-variable name="triggerConfig-Certificate" value="@( ((JObject)context.Variables[&quot;triggerConfigObject&quot;])[&quot;Certificate&quot;]?.ToString() ?? &quot;&quot; )" />\r\n    <!-- If trigger config certificate field is populated, we must receive a certificate -->\r\n    <choose>\r\n      <when condition="@( (string)context.Variables[&quot;triggerConfig-Certificate&quot;] != null &amp;&amp; (string)context.Variables[&quot;triggerConfig-Certificate&quot;] != &quot;&quot; &amp;&amp; context.Request.Certificate == null)">\r\n        <return-response>\r\n          <set-status code="403" reason="No certificate provided" />\r\n        </return-response>\r\n      </when>\r\n    </choose>\r\n    <!-- Check incoming certificate validity -->\r\n    <validate-client-certificate validate-revocation="false" validate-trust="false" validate-not-before="true" validate-not-after="true" ignore-error="false" />\r\n    <!-- Check certificate thumbprint with ExtensionsKit API -->\r\n    <set-variable name="incomingThumbprint" value="@(context.Request.Certificate.Thumbprint)" />\r\n    <set-variable name="tenantId" value="@( ((JObject)context.Variables[&quot;triggerResponseObject&quot;])[&quot;TenantId&quot;]?.ToString() ?? &quot;&quot; )" />\r\n    <send-request ignore-error="true" timeout="{{ExtensionsKitApiTimeout}}" response-variable-name="certificateResponse" mode="new">\r\n      <set-url>@("{{ExtensionsKitUri}}/api/v2/tenants/"+ (string) context.Variables["tenantId"] + "/certificates/" + (string)context.Variables["triggerConfig-Certificate"] + "/verification")</set-url>\r\n      <set-method>POST</set-method>\r\n      <set-header name="Authorization" exists-action="override">\r\n        <value>@("Bearer " + (string)context.Variables["idsAccessToken"])</value>\r\n      </set-header>\r\n      <set-header name="Content-Type" exists-action="override">\r\n        <value>application/json</value>\r\n      </set-header>\r\n      <set-body>@(new JObject(\r\n                    new JProperty("thumbprint",((string)context.Variables["incomingThumbprint"]))\r\n            ).ToString())</set-body>\r\n    </send-request>\r\n    <choose>\r\n      <!--  in case of timeouts, the value of certificateResponse is null -->\r\n      <when condition="@(((IResponse)context.Variables[&quot;certificateResponse&quot;]) == null)">\r\n        <return-response response-variable-name="certificateResponse">\r\n          <set-status code="429" reason="Too many request" />\r\n          <set-header name="Retry-After" exists-action="override">\r\n            <value>30</value>\r\n          </set-header>\r\n        </return-response>\r\n      </when>\r\n      <!--  Forward errors while checking certificate -->\r\n      <when condition="@(((IResponse)context.Variables[&quot;certificateResponse&quot;]).StatusCode != 200)">\r\n        <return-response response-variable-name="certificateResponse" />\r\n      </when>\r\n      <otherwise>\r\n        <set-variable name="certificateObject" value="@( ((IResponse)context.Variables[&quot;certificateResponse&quot;]).Body.As&lt;JObject&gt;())" />\r\n        <set-variable name="certificatesMatch" value="@{&#xA;                    return Convert.ToBoolean(((JObject)context.Variables[&quot;certificateObject&quot;])[&quot;certificatesMatch&quot;]);&#xA;                }" />\r\n        <choose>\r\n          <when condition="@( (bool) context.Variables[&quot;certificatesMatch&quot;] != true )">\r\n            <return-response>\r\n              <set-status code="403" reason="Certificates do not match" />\r\n            </return-response>\r\n          </when>\r\n        </choose>\r\n      </otherwise>\r\n    </choose>\r\n    <!--  Don\'t expose APIM subscription key to the backend. -->\r\n    <set-header name="Ocp-Apim-Subscription-Key" exists-action="delete" />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
  dependsOn: [
    apiManagementName_apiManagementWebhookName
    apiManagementName_IdentityServicesUri
    apiManagementName_ExtensionsKitWebhookV2Uri
  ]
}

resource apiManagementName_apiManagementWebhookName_v2_apiManagementWebhookSchemaName 'Microsoft.ApiManagement/service/apis/schemas@2021-08-01' = {
  parent: apiManagementName_apiManagementWebhookName_v2
  name: apiManagementWebhookSchemaName
  properties: {
    contentType: 'application/vnd.ms-azure-apim.swagger.definitions+json'
    document: {}
  }
  dependsOn: [
    apiManagementName_apiManagementWebhookName
  ]
}
