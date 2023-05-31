param customServiceName string
param serviceName string
param dnsTTL int = 60
param protocol string = 'TCP'
param port int = 443
param intervalInSeconds int = 30
param toleratedNumberOfFailures int = 3
param timeoutInSeconds int = 10
param primaryBIGIPURL string = ''
param u4costId string = ''

var externalEndpointId = resourceId(serviceName, 'Microsoft.Network/trafficManagerProfiles', trafficManagerProfile.name)

resource trafficManagerProfile 'Microsoft.Network/trafficManagerProfiles@2018-08-01' = {
  name: '${customServiceName}-test'
  location: 'global'
  tags: {
    U4COSTID: u4costId
  }
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Priority'
    dnsConfig: {
      relativeName: 'dnsConfigRelativeName'
      ttl: dnsTTL
    }
    monitorConfig: {
      protocol: protocol
      port: port
      intervalInSeconds: intervalInSeconds
      timeoutInSeconds: timeoutInSeconds
      toleratedNumberOfFailures: toleratedNumberOfFailures
    }
    trafficViewEnrollmentStatus: 'Disabled'
  }
  resource trafficManagerProfile 'ExternalEndpoints' = {
    id: externalEndpointId
    name: 'primary'
    properties: {
      target: primaryBIGIPURL
      endpointStatus: 'Enabled'
      weight: 1
      priority: 1
    }
  }
}
