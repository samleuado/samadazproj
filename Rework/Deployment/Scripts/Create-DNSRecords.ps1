param(

    [string] $customDomain,
    [string] $dnsZoneResourceGroupName,
    [string] $serviceNameSuffix,
    [string] $customServiceName,
    [string] $customDomainVerificationID
 
)

[string] [Parameter(Mandatory = $true)] $customDomain,
[string] [Parameter(Mandatory = $true)] $dnsZoneResourceGroupName,
[string] [Parameter(Mandatory = $true)] $appServiceSuffix,
[string] [Parameter(Mandatory = $true)] $customServiceName,
[string] [Parameter(Mandatory = $true)] $customDomainVerificationID

$Suffixes = $serviceNameSuffix.Split(',')
$RecordType = 'CNAME'
$RecordTTL = 3600

foreach ($Suffix in $Suffixes) {

    $RecordName = "$customServiceName-$Suffix"
    $EndPoint = "$customServiceName-$Suffix.trafficmanager.net"

    Write-Verbose "Adding $RecordName with endpoint $EndPoint in DNSZone $customDomain"

    Try {
        $DNSRecord = switch ($RecordType) {
            A { New-AzureRmDnsRecordConfig -IPv4Address $EndPoint }
            CNAME { New-AzureRmDnsRecordConfig -cname $EndPoint }
            TXT { New-AzureRmDnsRecordConfig -Value $EndPoint }
        }
        if ($null -eq (Get-AzureRmDnsRecordSet -ZoneName $customDomain -ResourceGroupName $dnsZoneResourceGroupName -Name $RecordName -RecordType $RecordType -ErrorAction SilentlyContinue)) {
            New-AzureRmDnsRecordSet -ZoneName $customDomain -ResourceGroupName $dnsZoneResourceGroupName -Name $RecordName -RecordType $RecordType -Ttl $RecordTTL -DnsRecords $DNSRecord 
        }
        else {
            New-AzureRmDnsRecordSet -ZoneName $customDomain -ResourceGroupName $dnsZoneResourceGroupName -Name "asuid.$customServiceName-$Suffix" -RecordType "TXT" -Ttl $RecordTTL -DnsRecords (New-AzureRmDnsRecordConfig -Value $customDomainVerificationID) -ErrorAction SilentlyContinue
        }
    }
    catch {
        throw "Creating DNS Records failed: $_"
    }
}