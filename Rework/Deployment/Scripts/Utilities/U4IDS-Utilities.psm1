function Disconnect-IdentityServicesInstance
{
    try { Disconnect-U4IDS -ErrorAction SilentlyContinue} catch [Exception] { }
}

function Connect-IdentityServicesInstance
{

	[CmdletBinding()]
	param(
		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$KeyVaultName,

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

	Write-Host "Connecting to identity services using $IdsAuthenticationMethod authentication"

	try
	{

		if ($IdsAuthenticationMethod -eq "Basic")
		{
			$idsBasicCredentials = New-Object System.Management.Automation.PSCredential($IdsUsername,(ConvertTo-SecureString $IdsPassword -AsPlainText -Force))
			Connect-U4IDS -IdsUri "$($IdsUrl)" -BasicAuth -Credential $idsBasicCredentials
		}
		elseif ($IdsAuthenticationMethod -eq "BasicWithVault") {
		
			$vaultUserName = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $IdsUsername -UseSuffix $false
			$vaultPassword = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $IdsPassword -UseSuffix $false

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
			Write-Host "Getting ClientId and Secret from vault $KeyVaultName"

			$vaultClient = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $IdsUsername -UseSuffix $false
			$vaultSecret = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $IdsPassword -UseSuffix $false

			$vaultSecretLength = $vaultSecret.length
			Write-Host "ClientId and Secret retrieved from KeyVault: $vaultClient/$vaultSecretLength"

			Connect-U4IDS -IdsUri "$($IdsUrl)" -ClientCredentialAuth -ClientId $vaultClient -ClientSecret $vaultSecret
		}
	}
	catch
	{
		Write-Host "Could not connect to identity services using $IdsAuthenticationMethod authentication"
		Write-Host $_.Exception.Message
		throw "An error occurred when attempting to connect to identity services. Script will stop"
	}
}


function Add-ClientToIds
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
		[string[]]$ClientScopes,

		[Parameter(ValueFromPipeline=$true)]
		[string[]]$Claims = $null,

		[Parameter(ValueFromPipeline=$true)]
		[bool]$PrefixClaims = $false

	)

	Write-Host "Creating client $ClientId in identity services"

    $newIdsClient = New-U4IDSClient -ClientId $ClientId -ClientName $ClientName -Flow ClientCredentials

	foreach ($clientScope in $ClientScopes)
	{
		$newIdsClient.AllowedScopes.Add($clientScope)
		Write-Host "Scope $clientScope Added to $ClientId"
	}

    if ($null -ne  $Claims) 
    {
        foreach ($claim in $Claims)
	    {
            $claimPair = $claim.Split(',');
            if ( 2 -eq $claimPair.length) 
            {
                $claim = New-U4IDSClientClaim -Type $claimPair[0] -Value $claimPair[1]
                $newIdsClient.Claims.Add($claim)
            }
		        
		    Write-Host "Claim $claim Added to $ClientId"
	    }    
    }

	$newIdsClient.PrefixClientClaims = $PrefixClaims
	$newIdsClient.AllowAccessToAllScopes = $false

	Write-Host "Adding client $ClientId to identity services"
    $newIdsClient = Add-U4IDSClient -Client $newIdsClient
	Write-Host "Client $ClientId Added to identity services"

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


function Add-ScopeToIds
{

	[CmdletBinding()]
	param(

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$Scope,
		
		[Parameter()]
        [ValidateNotNullorEmpty()]
		[string]$DisplayName 
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

function Use-ExtensionKitIdentity
{

	[CmdletBinding()]
	param(
		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$KeyVaultName,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$ClientId,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$ClientName,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		$ClientScopes,

        [Parameter(ValueFromPipeline=$true)]
		[string[]]$Claims = $null,

		[Parameter(ValueFromPipeline=$true)]
		[bool]$PrefixClaims = $false
	)

	# Check to see if the client has already been provisioned in identity services.

	Write-Host "Checking to see if identity $ClientId exists in identity services."

	$existingClient = Get-U4IDSClient -ClientId $ClientId -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
	
	if ($null -eq $existingClient)
	{
		
			Write-Host "Identity $ClientId does not exist in identity services, provisioning client now with allowed scopes $ClientScopes"

			$clientSecret = Add-ClientToIds -ClientId $ClientId -ClientName $ClientName -ClientScopes $ClientScopes -Claims $Claims -PrefixClaims $PrefixClaims

			# Store the client secret in the secure key vault for subsequent use if the script needs to be run more than once.

			Write-ClientSecretIntoVault -KeyVaultName $KeyVaultName -ClientId $ClientId -ClientSecret $clientSecret
		
	}
	else
	{
		Write-Host "Identity $ClientId has already been provisioned in identity services, no provisioning required."

		Update-ClientScopes -ClientId $ClientId -IdsClient $existingClient -ClientScopes $ClientScopes

		$clientSecret = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $ClientId
        if ($null -eq $clientSecret) 
        {
            throw "Could not read secret for $ClientId from the Azure Vault"
        }
	}

	$Result = @{
		ClientId = $ClientId
		ClientSecret = $clientSecret
	}
     Write-Host "Identity to be used $ClientId - $clientSecret"
	$Result
}

function Update-ClientScopes
{
	[CmdletBinding()]
	param(
		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$ClientId,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		$IdsClient,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		$ClientScopes
	)
	
	Write-Host "Updating scopes for client $ClientId"

	if ($null -ne $IdsClient)
	{
		$IdsClient.AllowedScopes.Clear()

		foreach ($clientScope in $ClientScopes)
		{
			$IdsClient.AllowedScopes.Add($clientScope)
			Write-Host "Added scope $clientScope"
		}

		Set-U4IDSClient $IdsClient
	}
	else
	{
		Write-Host "Client $ClientId is null, nothing to do"
	}
}

function Add-ExtensionKitPortalIdentity
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
		[string[]]$ClientScopes,

		[Parameter(ValueFromPipeline=$true)]
		[ValidateNotNullorEmpty()]
		[string]$PortalUrl

	)

	Write-Host "Creating client $ClientId in identity services"
	
    $newIdsClient = New-U4IDSClient -ClientId $ClientId -ClientName $ClientName -Flow AuthorizationCodeWithProofKey   
	
	foreach ($clientScope in $ClientScopes)
	{
		$newIdsClient.AllowedScopes.Add($clientScope)
		Write-Host "Scope $clientScope Added to $ClientId"
	}

	$newIdsClient.IdentityTokenLifetime = 3600
	$newIdsClient.AllowAccessToAllScopes = $false
	$newIdsClient.RedirectUris.Add("$PortalUrl/signin-oidc")
	$newIdsClient.PostLogoutRedirectUris.Add("$PortalUrl/signout-callback-oidc")

	Write-Host "Adding client $ClientId to identity services"
	$newIdsClient = Add-U4IDSClient -Client $newIdsClient
	Write-Host "Client $ClientId Added to identity services"

	$clientSecret = Add-U4IDSClientSecret -ClientId $newIdsClient.ClientId -Description "$($newIdsClient.ClientId) secret" -Expiration (New-U4IDSSecretExpiration -Never)

	Write-Host "Created CLIENT : $($newIdsClient.ClientId) ($($newIdsClient.ClientName)) with secret '$($clientSecret.Value)'"
	Write-Host "    ->  SCOPES : $($newIdsClient.AllowedScopes)"

	return $clientSecret.Value
}

function Use-ExtensionKitPortalIdentity
{

	[CmdletBinding()]
	param(
		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$KeyVaultName,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$ClientId,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$ClientName,

		[Parameter(ValueFromPipeline=$true)]
		[ValidateNotNullorEmpty()]
		[string[]]$ClientScopes,

		[Parameter(ValueFromPipeline=$true)]
		[ValidateNotNullorEmpty()]
		[string]$PortalUrl
	)

	# Check to see if the client has already been provisioned in identity services.

	Write-Host "Checking to see if identity $ClientId exists in identity services."

	$existingClient = Get-U4IDSClient -ClientId $ClientId -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
	
	if ($null -eq $existingClient)
	{

		if (!$NoIds)
		{
			Write-Host "Identity $ClientId does not exist in identity services, provisioning client now with allowed scopes $ClientScopes"

			$clientSecret = Add-ExtensionKitPortalIdentity -ClientId $ClientId -ClientName $ClientName -ClientScopes $ClientScopes -PortalUrl $PortalUrl

			# Store the client secret in the secure key vault for subsequent use if the script needs to be run more than once.

			Write-ClientSecretIntoVault -KeyVaultName $KeyVaultName -ClientId $ClientId -ClientSecret $clientSecret
		}
		else
		{
			throw "A required identity $ClientId for the Extension Kit needs to be provisioned, but the -NoIds switch has been set. Script cannot continue."
		}
	}
	else
	{
		Write-Host "Identity $ClientId has already been provisioned in identity services, no provisioning required."

		$clientSecret = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $ClientId
        if ($null -eq $clientSecret) 
        {
            throw "Could not read secret for $ClientId from the Azure Vault"
        }

	}

	$Result = @{
		ClientId = $ClientId
		ClientSecret = $clientSecret
	}
    Write-Host "Identity to be used $ClientId - $clientSecret"

	$Result
}
