param(

    [Parameter(Mandatory = $true)][string] $AddDNSRecords,
    [string] $CustomDomain,
    [string] $DNSZoneResourceGroupName,
    [string] $ServiceNameSuffix,
    [string] $CustomServiceName,
    [string] $CustomDomainVerificationID
 
)

if ($AddDNSRecords -eq 'yes') {

    [string] [Parameter(Mandatory = $true)] $CustomDomain,
    [string] [Parameter(Mandatory = $true)] $DNSZoneResourceGroupName,
    [string] [Parameter(Mandatory = $true)] $appServiceSuffix,
    [string] [Parameter(Mandatory = $true)] $CustomServiceName,
    [string] [Parameter(Mandatory = $true)] $CustomDomainVerificationID

    $Suffixes = $ServiceNameSuffix.Split(',')
    $RecordType = 'CNAME'
    $RecordTTL = 3600
    
    
    foreach ($Suffix in $Suffixes) {

        $RecordName = "$CustomServiceName-$Suffix"
        $EndPoint = "$CustomServiceName-$Suffix.trafficmanager.net"

        Write-Verbose "Adding $RecordName with endpoint $EndPoint in DNSZone $CustomDomain"

        Try {
            $DNSRecord = switch ($RecordType) {
                A { New-AzureRmDnsRecordConfig -IPv4Address $EndPoint }
                CNAME { New-AzureRmDnsRecordConfig -cname $EndPoint }
                TXT { New-AzureRmDnsRecordConfig -Value $EndPoint }
            }
            if ($null -eq (Get-AzureRmDnsRecordSet -ZoneName $CustomDomain -ResourceGroupName $DNSZoneResourceGroupName -Name $RecordName -RecordType $RecordType -ErrorAction SilentlyContinue)) {
                New-AzureRmDnsRecordSet -ZoneName $CustomDomain -ResourceGroupName $DNSZoneResourceGroupName -Name $RecordName -RecordType $RecordType -Ttl $RecordTTL -DnsRecords $DNSRecord 
            }
            else {
                New-AzureRmDnsRecordSet -ZoneName $CustomDomain -ResourceGroupName $DNSZoneResourceGroupName -Name "asuid.$CustomServiceName-$Suffix" -RecordType "TXT" -Ttl $RecordTTL -DnsRecords (New-AzureRmDnsRecordConfig -Value $CustomDomainVerificationID) -ErrorAction SilentlyContinue
            }
        }
        catch {
            throw "Creating DNS Records failed: $_"
        }
    }
}
else {
    Write-Verbose "Creating DNS Records has not been requested. Skipping task."
}