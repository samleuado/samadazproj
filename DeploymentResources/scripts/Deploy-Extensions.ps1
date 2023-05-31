[CmdletBinding()]
param(
    # The Extension Kit service base name
    [Parameter()]
    [ValidateNotNullorEmpty()]
    [string]$ExtensionKitServiceName,

	# Custom Service Name
	[Parameter()]
	[AllowEmptyString()]
	[string]$CustomServiceName,
    
    # Name of a secure key vault which is available on the azure subscription under which this script is running.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$KeyVaultName,
    
    # The url domain to be used with the publicly reacheable services
    [Parameter()]
    [AllowEmptyString()]
    [string]$CustomDomain = "azurewebsites.net",
    
    # The url of Identity Services
    [Parameter()]
    [ValidateNotNullorEmpty()]
    [string]$IdsAuthority,
    
    # The path to the metadata Json file
    [Parameter()]
    [ValidateNotNullorEmpty()]
    [string]$MetadataJsonPath,

    # The path where the script is running
	[Parameter()]
	[AllowEmptyString()]
	[string]$WorkingDirectory = ".\"
)

Function Get-IdsAccessToken {
    $extensionKitInternalClientId = "$ExtensionKitServiceName-internal"
    $extensionKitInternalClientSecret = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $extensionKitInternalClientId

    $tokenEndpoint = "$IdsAuthority/identity/connect/token"
    $payload = @{
        grant_type = "client_credentials"
        client_id = $extensionKitInternalClientId
        client_secret = $extensionKitInternalClientSecret
        scope = "u4ek-public-api"
    };

    Write-Host "Retrieving new access token from authority endpoint $tokenEndpoint"
    
    $response = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $payload -ContentType 'application/x-www-form-urlencoded' -Verbose
    $token = $response.access_token
    
    Write-Host "Access token retrieved"

    return $token
}

Function Upload-ActionMetadata {
    param(
		[ValidateNotNullorEmpty()]
		[string]$JsonPath,

		[ValidateNotNullorEmpty()]
		[string]$ApiBaseUrl,

		[ValidateNotNullorEmpty()]
		[string]$AccessToken
    )

    Write-Host "Reading Metadata from Json file"
    $jsonContent = Get-Content $JsonPath 
    $headers = @{
        Authorization="Bearer $AccessToken"
    }
    
    Write-Host "Uploading metadata to Extensions API"
    Invoke-RestMethod -Uri "$ApiBaseUrl/api/v1/actions" -Method PUT -Headers $headers -Body $jsonContent -ContentType 'application/json'
}

Write-Host "Deploy Extension - Started"

Import-Module "$WorkingDirectory\AzureVault-Utilities.psm1" -Force

if ([string]::IsNullOrEmpty($CustomServiceName)) {
    $CustomServiceName = $ExtensionKitServiceName
}

if ([string]::IsNullOrEmpty($CustomDomain)) {
    $CustomDomain = "azurewebsites.net"
}

$extensionsApiUri = "https://$CustomServiceName-extensions.$CustomDomain"

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
$accessToken = Get-IdsAccessToken
Upload-ActionMetadata -JsonPath $MetadataJsonPath -ApiBaseUrl $extensionsApiUri -AccessToken $accessToken 
