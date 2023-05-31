param (
    [string]$addIPAllowListing,
    [string]$PrimaryFQDN,
    [string]$SecondaryFQDN,
    [string]$FileName="AllowedIPs.txt"
)

if ($addIPAllowListing -eq 'yes') {
    Write-Verbose "Fetching for all Load balancers in Azure subscription."
    $alb_list = Get-AzureRmLoadBalancer
    Write-Verbose "Searching for public IP associated with '$PrimaryFQDN' FQDN."
    $pip_primary = Get-AzureRmPublicIpAddress|Where-Object {$_.DnsSettings.Fqdn -eq $PrimaryFQDN}

    if(-not $pip_primary ){
        Write-Warning "Unable to determine primary public IP"
    }
    else{
        Write-Verbose ("Searching for load balancer with following PIP with resource ID: '" + $pip_primary.Id + "'")
        $alb_list|%{
            if($_.FrontendIpConfigurations.PublicIpAddress.Id -contains $pip_primary.Id){
                $index = $alb_list.IndexOf($_)
            }
        }
        $alb_primary = $alb_list[$index]
    }
    
    $alb_primary_IPs = @()
    if($alb_primary){
        Write-Verbose ("Found load balancer: " + $alb_primary.Name)
        $frontend_ips_primary = Get-AzureRmLoadBalancerFrontendIpConfig -LoadBalancer $alb_primary
        $frontend_ips_primary.PublicIpAddress.Id|ForEach-Object{
            $alb_primary_IPs += (Get-AzureRmResource -ResourceId $_|Get-AzureRmPublicIpAddress).Ipaddress
        }
    }
    else{
        Write-Error "Primary Load balancer has not been found."
    }

    if ($SecondaryFQDN) {
        Write-Verbose "Searching for public IP associated with '$SecondaryFQDN' FQDN."
        $pip_secondary = Get-AzureRmPublicIpAddress|Where-Object {$_.DnsSettings.Fqdn -eq $SecondaryFQDN}
    
        if( -not $pip_secondary ){
            Write-Warning "Unable to determine secondary public IP"
        }
        else{
            Write-Verbose ("Searching for load balancer with following PIP with resource ID: '" + $pip_secondary.Id + "'")
            $alb_list|%{
                if($_.FrontendIpConfigurations.PublicIpAddress.Id -contains $pip_secondary.Id){
                    $index = $alb_list.IndexOf($_)
                }
            }
            $alb_secondary = $alb_list[$index]
        }

        $alb_secondary_IPs = @()
        if($alb_secondary){
            Write-Verbose ("Found load balancer: " + $alb_secondary.Name)
            $frontend_ips_secondary = Get-AzureRmLoadBalancerFrontendIpConfig -LoadBalancer $alb_secondary
            $frontend_ips_secondary.PublicIpAddress.Id|ForEach-Object{
                $alb_secondary_IPs += (Get-AzureRmResource -ResourceId $_|Get-AzureRmPublicIpAddress).Ipaddress
            }
        }
        else{
            Write-Error "Secondary Load balancer has not been found." 
        }
    }

    Clear-Variable IPstoAdd -ErrorAction SilentlyContinue
    if ($alb_primary_IPs) { $IPstoAdd += $alb_primary_IPs }
    if ($alb_secondary_IPs) { $IPstoAdd += $alb_secondary_IPs }

    Write-Verbose "Saving IPs to file $(Split-Path $myInvocation.MyCommand.Path)\$FileName"
    $IPstoAdd | Out-File "$(Split-Path $myInvocation.MyCommand.Path)\$FileName"
}
else {
    Write-Verbose "IP Allow Listing has not been requested. Skipping this task"
}