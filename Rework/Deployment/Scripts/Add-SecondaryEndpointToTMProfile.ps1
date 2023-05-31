param(
    [string]$CustomServiceName,
    [string]$TMResourceGroupName,
    [string]$SecondaryResourceGroupName,
    [string]$ServiceNameSuffix,
    [string]$ExternalEndpoint,
    [ValidateSet('AzureEndpoints','ExternalEndpoints','NestedEndpoints')][string]$EndpointType
)

if ($SecondaryResourceGroupName -or $ExternalEndpoint) {

    if ($null -eq (Get-AzureRmContext).Account) 
    {
        throw "No Azure RM Context available. Script will stop"
    }
    $Suffixes = $ServiceNameSuffix.Split(',')

    foreach ($Suffix in $Suffixes) {

        $TmProfileName = "$CustomServiceName-$Suffix"

        Try {
            $TmProfile = Get-AzureRmTrafficManagerProfile -Name $TmProfileName -ResourceGroupName $TMResourceGroupName -ErrorAction Stop
            switch($EndpointType) 
            {
                AzureEndpoints 
                {
                    $TargetURI = "$SecondaryResourceGroupName-$Suffix"
                    $webapp = Get-AzurermWebApp -Name $TargetURI -ErrorAction Stop
                    Add-AzureRmTrafficManagerEndpointConfig -EndpointName secondary -TrafficManagerProfile $TmProfile -Type $EndpointType -TargetResourceId $webapp.Id -EndpointStatus Enabled -ErrorAction Stop
                }
                ExternalEndpoints
                {
                    $TargetURI = $ExternalEndpoint
                    Add-AzureRmTrafficManagerEndpointConfig -EndpointName secondary -TrafficManagerProfile $TmProfile -Type $EndpointType -Target $TargetURI -EndpointStatus Enabled -ErrorAction Stop
                }
                NestedEndpoints
                {
                    Throw "NestedEndpoints type is not supported by this script."
                }
            }
            Set-AzureRmTrafficManagerProfile -TrafficManagerProfile $TmProfile -ErrorAction Stop
            Write-Host "$TargetURI has been added as a secondary Endpoint to $TmProfile"
        }
        Catch {
            Throw "Adding Endpoint failed: $_"
        }
    }
}
else {
    Write-Verbose "TargetURI is not provided. Skipping task."
}