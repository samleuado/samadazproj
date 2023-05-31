param customServiceName string
param serviceNameSuffix string
param primaryTarget string
param dnsTTL int = 60
param protocol string = 'TCP'
param port int = 443
param intervalInSeconds int = 30
param toleratedNumberOfFailures int = 3
param timeoutInSeconds int = 10
param u4costId string = ''

var serviceNameSuffixes = split(serviceNameSuffix, ',')

resource customServiceName_serviceNameSuffixes 'Microsoft.Network/trafficManagerProfiles@2018-04-01' = [for item in serviceNameSuffixes: {
  name: '${customServiceName}-${item}'
  location: 'global'
  tags: {
    U4COSTID: u4costId
  }
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Priority'
    dnsConfig: {
      relativeName: '${customServiceName}-${item}'
      ttl: dnsTTL
    }
    monitorConfig: {
      protocol: protocol
      port: port
      intervalInSeconds: intervalInSeconds
      toleratedNumberOfFailures: toleratedNumberOfFailures
      timeoutInSeconds: timeoutInSeconds
    }
    endpoints: [
      {
        id: '${resourceId('Microsoft.Network/trafficManagerProfiles', '${customServiceName}-${item}')}/externalEndpoints/primary'
        name: 'primary'
        type: 'Microsoft.Network/trafficManagerProfiles/externalEndpoints'
        properties: {
          endpointStatus: 'Enabled'
          target: primaryTarget
          weight: 1
          priority: 1
        }
      }
    ]
    trafficViewEnrollmentStatus: 'Disabled'
  }
}]
