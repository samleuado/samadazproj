param (
    [string]$serviceName,
    [string]$resourceGroupName,
    [string]$serviceNameGEO,
    [string]$resourceGroupNameGeo,
    [string]$customServiceName,
    [string]$customDomain,
    [string]$serviceNameSuffix
)

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$serviceName,
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$resourceGroupName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$customServiceName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$customDomain,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$serviceNameSuffix

    # sleep before TM is updated on webapp. 
    sleep 60

    $Suffixes = $serviceNameSuffix.Split(',')

    foreach ($Suffix in $Suffixes) {

        # Public URI
        $ServiceTmDnsName = "$customServiceName-$Suffix.$customDomain"

        # Azure URIs
        $PrimaryAzureUri = "$serviceName-$Suffix.azurewebsites.net"
        if ($serviceNameGEO) { $secondaryAzureUri = "$serviceNameGEO-$Suffix.azurewebsites.net" }
        
        Try {
            Write-Verbose "Setting hostnames for $serviceName-$Suffix : $ServiceTmDnsName ..."
            Set-AzureRMWebApp -Name "$serviceName-$Suffix" -ResourceGroupName $resourceGroupName -HostNames @($ServiceTmDnsName, $PrimaryAzureUri)

            if ($serviceNameGEO) {
                Write-Verbose "Setting hostname for $serviceNameGEO-$Suffix : $ServiceTmDnsName ..."
                Set-AzureRMWebApp -Name "$serviceNameGEO-$Suffix" -ResourceGroupName $resourceGroupNameGeo -HostNames @($ServiceTmDnsName, $SecondaryAzureUri)
            }
        }
        Catch {
            Throw "Adding Custom Domain failed: $_" 
        }
    }