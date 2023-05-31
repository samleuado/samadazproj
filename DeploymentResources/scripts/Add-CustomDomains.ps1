param (
    [string]$ServiceName,
    [string]$ResourceGroupName,
    [string]$ServiceNameGeo,
    [string]$ResourceGroupNameGeo,
    [string]$CustomServiceName,
    [string]$CustomDomain,
    [string]$ServiceNameSuffix,
    [string]$DeploymentModel
)

if ($DeploymentModel -eq 'SaaS') {

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ServiceName,
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$CustomServiceName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$CustomDomain,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ServiceNameSuffix

    # sleep before TM is updated on webapp. 
    sleep 60

    $Suffixes = $ServiceNameSuffix.Split(',')

    foreach ($Suffix in $Suffixes) {

        # Public URI
        $ServiceTmDnsName = "$CustomServiceName-$Suffix.$CustomDomain"

        # Azure URIs
        $PrimaryAzureUri = "$ServiceName-$Suffix.azurewebsites.net"
        if ($ServiceNameGeo) { $secondaryAzureUri = "$ServiceNameGeo-$Suffix.azurewebsites.net" }
        
        Try {
            Write-Verbose "Setting hostnames for $ServiceName-$Suffix : $ServiceTmDnsName ..."
            Set-AzureRMWebApp -Name "$ServiceName-$Suffix" -ResourceGroupName $ResourceGroupName -HostNames @($ServiceTmDnsName, $PrimaryAzureUri)

            if ($ServiceNameGeo) {
                Write-Verbose "Setting hostname for $ServiceNameGeo-$Suffix : $ServiceTmDnsName ..."
                Set-AzureRMWebApp -Name "$ServiceNameGeo-$Suffix" -ResourceGroupName $ResourceGroupNameGeo -HostNames @($ServiceTmDnsName, $SecondaryAzureUri)
            }
        }
        Catch {
            Throw "Adding Custom Domain failed: $_" 
        }
    }
}
else {
    Write-Host "Deployment model is $DeploymentModel. Skipping the task"
}