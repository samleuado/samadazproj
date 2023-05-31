[CmdletBinding()]
param(
    # The uri of the identity services endpoint, used to work with identity services and to obtain bearer tokens for calls to other micro-services.
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$IdsUrl,

    # What is the method to be used to connect to the Ids instance. 
    # Allowed values are Basic, BasicWithVault, Bearer or BearerWithVault
    #If using Basic authentication $IdsUsername and $IdsPassword will be used as user and password
    #If using BasicWithVault authentication $IdsUsername and $IdsPassword will be used as user's and password's vault key name
    #If using Bearer authentication $IdsUsername and $IdsPassword will be used as client and client secret
    #If using BearerWithVault authentication $IdsUsername and $IdsPassword will be used as client's and client secret's vault key name
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$IdsAuthenticationMethod,

    # Username used to connect to Ids instance if using Basic authentication
    # Username vault key name in case of BasicWithVault
    # Client Id if using Bearer authentication.
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$IdsUsername,

	# Password used to connect to Ids instance if using Basic authentication 
    # Password vault key name in case of BasicWithVault
    # Client Secret if using Bearer authentication.
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$IdsPassword,

    # Name of a secure key vault which is available on the azure subscription under which this script is running.
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$KeyVaultName,

    # The Extension Kit instance name to provision.
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionKitInstanceName,

	# The Extension Kit Source System name to provision.
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionKitSourceSystem,

	# The path where the script is running
	[Parameter()]
	[string]$WorkingDirectory = ".\"
)

function Connect-IdentityServices
{

	[CmdletBinding()]
	param(
		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$IdsUrl,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		$IdsAuthenticationMethod,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		$IdsUsername,

		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$IdsPassword

	)

	try { Disconnect-U4IDS -ErrorAction SilentlyContinue} catch [Exception] { }

	Write-Host "Connecting to identity services using $IdsAuthenticationMethod authentication ..."

	try
	{

		if ($IdsAuthenticationMethod -eq "Basic")
		{
			$idsBasicCredentials = New-Object System.Management.Automation.PSCredential($IdsUsername,(ConvertTo-SecureString $IdsPassword -AsPlainText -Force))
			Connect-U4IDS -IdsUri "$($IdsUrl)" -BasicAuth -Credential $idsBasicCredentials
		}
		elseif ($IdsAuthenticationMethod -eq "BasicWithVault") {
		
			$vaultUserName = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $IdsUsername
			$vaultPassword = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $IdsPassword

			Write-Host "vaultUserName: $vaultUserName, vaultPassword: $vaultPassword"

			$idsBasicCredentials = New-Object System.Management.Automation.PSCredential($vaultUserName,(ConvertTo-SecureString $vaultPassword -AsPlainText -Force))
			Connect-U4IDS -IdsUri "$($IdsUrl)" -BasicAuth -Credential $idsBasicCredentials
		}
		elseif ($IdsAuthenticationMethod -eq "Bearer")
		{
			Connect-U4IDS -IdsUri "$($IdsUrl)" -ClientCredentialAuth -ClientId $IdsUsername -ClientSecret $IdsPassword
		}
		elseif ($IdsAuthenticationMethod -eq "BearerWithVault")
		{
			$vaultClient = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $IdsUsername
			$vaultSecret = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $IdsPassword
			Connect-U4IDS -IdsUri "$($IdsUrl)" -ClientCredentialAuth -ClientId $vaultClient -ClientSecret $vaultSecret
		}
	}
	catch
	{
		Write-Host "Could not connect to identity services using $IdsAuthenticationMethod authentication ..."
		Write-Host $Error
		throw "An error occurred when attempting to connect to identity services. Script will stop"
	}
}


function Create-Client
{

	[CmdletBinding()]
	param(
		[Parameter(ValueFromPipeline=$true)]
		[ValidateNotNullorEmpty()]
		[string]$ClientId,

		[Parameter(ValueFromPipeline=$true)]
		[ValidateNotNullorEmpty()]
		[string]$ClientName,

		[Parameter(ValueFromPipeline=$true)]
		[ValidateNotNullorEmpty()]
		[string[]]$ClientScopes

	)

	Write-Host "Creating client $ClientId in identity services..."

    $newIdsClient = New-U4IDSClient -ClientId $ClientId -ClientName $ClientName -Flow ClientCredentials

	foreach ($clientScope in $ClientScopes)
	{
		$newIdsClient.AllowedScopes.Add($clientScope)
		Write-Host "Scope $clientScope Added to $ClientId"
	}

	$newIdsClient.PrefixClientClaims = $true
	$newIdsClient.AllowAccessToAllScopes = $false

	Write-Host "Adding client $ClientId to identity services..."
    $newIdsClient = Add-U4IDSClient -Client $newIdsClient
	Write-Host "Client $ClientId Added to identity services ..."

	$clientSecret = $newIdsClient.Secrets[0].Value

	Write-Host "Created CLIENT : $($newIdsClient.ClientId) ($($newIdsClient.ClientName)) with secret '$clientSecret'"
	Write-Host "    ->  SCOPES : $($newIdsClient.AllowedScopes)"

	$clientSecret
}

function Add-ScopeToClient 
{

	[CmdletBinding()]
	param
	(

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$ClientId,

        [Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$Scope
    )

    $client = Get-U4IDSClient -ClientId $ClientId    
    if ($false -eq $client.AllowedScopes.Contains($Scope)) {
        $client.AllowedScopes.Add($Scope)
        Set-U4IDSClient -Client $client
    }    
}


function Provision-ExtensionKitIdsApiScope
{

	[CmdletBinding()]
	param(

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$Scope,
		
		[Parameter()]
		[string]$DisplayName = "Extension Kit Api Scope"
	)

	
	# Check to see if the scope has already been provisioned in identity services.

	Write-Host "Checking to see if scope $Scope exists in identity services."

	$existingScope = Get-U4IDSScope -Name $Scope -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

	if ($null -eq $existingScope)
	{
		Write-Host "Scope $Scope does not exist in identity services, provisioning scope now."
					
		$newIdsScope = New-U4IDSScope -Name $Scope -DisplayName $DisplayName
		$newIdsScope.IncludeAllClaimsForUser = $true
		$newIdsScope = Add-U4IDSScope -Scope $newIdsScope
	}
	else
	{
		Write-Host "Scope $Scope has already been provisioned in identity services, no provisioning required."
	}
	

	return $null
}

function Provision-ExtensionKitIdsIdentity
{

	[CmdletBinding()]
	param(

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$ClientId,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$ClientName,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		$ClientScopes
	)

	# Check to see if the client has already been provisioned in identity services.

	Write-Host "Checking to see if identity $ClientId exists in identity services."

	$existingClient = Get-U4IDSClient -ClientId $ClientId -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
	
	if ($null -eq $existingClient)
	{


		
			Write-Host "Identity $ClientId does not exist in identity services, provisioning client now with allowed scopes $ClientScopes"

			$clientSecret = Create-Client -ClientId $ClientId -ClientName $ClientName -ClientScopes $ClientScopes

			# Store the client secret in the secure key vault for subsequent use if the script needs to be run more than once.

			Put-ClientSecretIntoVault -ClientId $ClientId -ClientSecret $clientSecret
		
	}
	else
	{
		Write-Host "Identity $ClientId has already been provisioned in identity services, no provisioning required."

		$clientSecret = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $ClientId

        if (null -eq- $clientSecret) 
        {
            throw "Could not read secret for $ClientId from the Azure Vault"
        }
	}

	$Result = @{
		ClientId = $ClientId
		ClientSecret = $clientSecret
	}
     Write-Host "Identity to be used $ClientId - $clientSecret  ..."
	$Result
}


# Initialize some variables
$extensionKitApiScope = "u4ek-public-api"
$extensionKitServiceName = "$ExtensionKitSourceSystem-$ExtensionKitInstanceName"

$extensionKitInternalClientId = "$extensionKitServiceName-internal"
$extensionKitPortalClientId = "$extensionKitServiceName-portal"


Import-Module "$WorkingDirectory\Provision-Helpers.psm1"
# Install-NuGetPackage -NugetFeedName 'U4PP' -NugetFeedUri 'https://packages.u4pp.com/nuget/nuget/' -ModuleName "U4.IdentityServices.PowerShell" -MinimumVersion "1.0.0.0"


if ($null -eq (Get-AzureRmContext).Account) 
{
    throw "No Azure RM Context available. Script will stop"
}


Connect-IdentityServicesInstance -KeyVaultName $KeyVaultName -IdsUrl $IdsUrl -IdsAuthenticationMethod $IdsAuthenticationMethod -IdsUsername $IdsUsername -IdsPassword $IdsPassword
Write-Host "Connected"


#
#	Provision the Extension Kit Public Api scope in identity services.
#
Provision-ExtensionKitIdsApiScope -Scope $extensionKitApiScope

#
#	Provision the Extension Kit Public Api automation scope scope in identity services.
#
Provision-ExtensionKitIdsApiScope -Scope "u4ek-automation" -DisplayName "ExtensionKit Automation Scope"


$identityCreationResult = Provision-ExtensionKitIdsIdentity -ClientId $extensionKitInternalClientId -ClientScopes "u4mh-accessprovider","u4mh-actor-relay","u4mh-director-relay", "u4mh-sourcesystem-publish", "u4mh-tenant-receive", $extensionKitApiScope -ClientName "Extension Kit ($extensionKitServiceName) Internal Identity"

