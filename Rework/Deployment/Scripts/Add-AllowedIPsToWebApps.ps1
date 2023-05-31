    <#
.Synopsis
    Add "IP restrictions" (allowlist) to an Azure web app. 
.DESCRIPTION
    IP restrictions allow you to define a static list of IP addresses that are allowed access to your app. 
    
    The requests to this app from an IP address not in this list will get an HTTP 403 Forbidden response. 
    
.EXAMPLE
    Get IP addresses on the fly
    .\Add-AllowedIPsToWebApps.ps1 -PrimaryFQDN PrimaryFQDN -SecondaryFQDN SecondaryFQDN -ResourceGroupName t-eun-ek1 -ResourceName t-eun-ek1-functions -FileName "D:\DevAgr\Cloud\Azure\PowerShell\IDS\SaaS\iplist.txt"

    Fetch IP adresses from file
    .\Add-AllowedIPsToWebApps.ps1 -ResourceGroupName t-eun-ek1 -ResourceName t-eun-ek1-functions -FileName "D:\DevAgr\Cloud\Azure\PowerShell\IDS\SaaS\iplist.txt"

    Input file format:
    <IP address>/<subnet mask>

    If the subnet mask isn't added in the input file, the script will append /32"
    
    Example text file:

    52.178.153.243
    13.79.232.43
    195.1.61.4

    Example text file for "allow all IP addresses":

    0.0.0.0/0

#>

[CmdletBinding()]
param (
    [string]$addIPAllowListing,
    [Parameter(HelpMessage="Resource group name")]
    [string]$ResourceGroupName,
    [string]$FileName,
    [string]$ServiceName,
    [string]$ServiceNameSuffix
)

if ($addIPAllowListing -eq 'yes') {

[ValidateNotNullorEmpty()][string]$ServiceName,
[ValidateNotNullorEmpty()][string]$ResourceGroupName,
[ValidateNotNullorEmpty()][string]$FileName,
[ValidateNotNullorEmpty()][string]$ServiceNameSuffix
$Suffixes = $ServiceNameSuffix.Split(',')

Write-Verbose "Getting IPs from $(Split-Path $myInvocation.MyCommand.Path)\$FileName."
Push-Location -Path (Split-Path $myInvocation.MyCommand.Path)
if (-not (Test-Path -Path $FileName)) { throw "Could not find the IP list file $FileName" }
$IPstoAdd = Get-Content -Path $FileName -ErrorAction Stop

Write-Verbose "Fetched IPs:`n$IPstoAdd"

foreach ($Suffix in $Suffixes) {
    $ResourceName = "$ServiceName-$Suffix"
    try
    {
    #The list of Traffic Manager IPs can be found in the FAQ:
    #https://docs.microsoft.com/en-us/azure/traffic-manager/traffic-manager-faqs
    #https://azuretrafficmanagerdata.blob.core.windows.net/probes/azure/probe-ip-ranges.json

        Write-Verbose "Adding allowed ips to $ResourceGroupName - $ResourceName/web/ of type 'Microsoft.Web/sites/config' ..."
        $resource = Get-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/config -ResourceName "$ResourceName/web/" -ApiVersion 2018-02-01

        $p = $resource.Properties
        $p.ipSecurityRestrictions = @()
        $priority = 100;
        foreach ($ip in $IPstoAdd)
        {
            $restriction = @{}
            $restriction.Add("priority", $priority.ToString() )
            if (!($ip.Contains("/")))
            {
                $ip += "/32"
            }
            $restriction.Add("ipAddress",$ip)
            $p.ipSecurityRestrictions+= $restriction
            $priority += 100;
        }

        Set-AzureRmResource -ResourceGroupName  $ResourceGroupName -ResourceType Microsoft.Web/sites/config -ResourceName "$ResourceName/web/" -ApiVersion 2018-02-01 -PropertyObject $p -Force
        Write-Verbose "Allowed ips added to $ResoruceGroupName - $ResourceName/web/ of type 'Microsoft.Web/sites/config'."

    }
    catch
    {
        Write-Error "Script Add-IPRestrictionsToWebApps failed: $($PSItem.ToString())"
    }
}
}
else {
Write-Verbose "IP Allow Listing has not been requested. Skipping this task"
}