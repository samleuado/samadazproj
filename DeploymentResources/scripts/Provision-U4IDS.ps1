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

	# The Extension Kit source system name to provision.
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionKitSourceSystem,

	# The Extension Kit service base name
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionKitServiceName,
	
	# The name of the message hub instance against which the Extension Kit instance will run.
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$MessageHubInstanceName,

    # the url domain to be used with the publicly reacheable services
	[Parameter()]
	[AllowEmptyString()]
	[string]$CustomDomain,

    # the url domain to be used with the publicly reacheable services
	[Parameter()]
	[AllowEmptyString()]
	[string]$NugetRepository = "nuget",

	# The path where the script is running
	[Parameter()]
	[AllowEmptyString()]
	[string]$WorkingDirectory = ".\",

	[Parameter()]
	[AllowEmptyString()]
	[string]$CustomServiceName
)

Write-Host "Provision U4IDS"

Import-Module "$WorkingDirectory\Nuget-Utilities.psm1" -Force
Import-Module "$WorkingDirectory\AzureVault-Utilities.psm1" -Force
Import-Module "$WorkingDirectory\U4IDS-Utilities.psm1" -Force

$accessManagementApiScope = "u4am-public-api"

$extensionKitApiScope = "u4ek-public-api"
$extensionKitAutomationScope = "u4ek-automation"
$extensionKitHibernateScope = "u4ek-hibernate"
$extensionKitAwakeScope = "u4ek-awake"
$daPushScope = "u4da-push"
$extensionKitTenantsReadScope = "u4ek-tenant-read"
$extensionKitTenantsManageScope = "u4ek-tenant-manage"
$extensionKitMarketplaceScope = "u4ek-market"

$extensionKitInternalClientId = "$ExtensionKitServiceName-internal"
$extensionKitProvisionerClientId = "$ExtensionKitServiceName-provisioner"
$extensionKitPortalClientId = "$ExtensionKitServiceName-portal-pkce"
$extensionKitPowershellClientId = "$ExtensionKitServiceName-powershell-admin"

if([string]::IsNullOrEmpty($CustomServiceName)) 
{
		$CustomServiceName = $ExtensionKitServiceName
}


$resolvedCustomDomain = $CustomDomain;
if([string]::IsNullOrEmpty($resolvedCustomDomain)) 
{
		$resolvedCustomDomain = "azurewebsites.net"
}

$extensionKitPortalUrl = "https://$CustomServiceName-portal.$resolvedCustomDomain"

Install-NuGetPackage -NugetFeedName "U4PP" -NugetFeedUri "https://packages.u4pp.com/$NugetRepository/nuget/" -ModuleName "U4.IdentityServices.PowerShell" -MinimumVersion "1.0.0.0"

if ($null -eq (Get-AzContext).Account) 
{
    throw "No Azure RM Context available. Script will stop"
}

Connect-IdentityServicesInstance -KeyVaultName $KeyVaultName -IdsUrl $IdsUrl -IdsAuthenticationMethod $IdsAuthenticationMethod -IdsUsername $IdsUsername -IdsPassword $IdsPassword
Write-Host "Connected"

#
#	Provision the Extension Kit Public Api scope in identity services.
#

Add-ScopeToIds -Scope $extensionKitApiScope -DisplayName "Extension Kit Api Scope"

#
#	Provision the Extension Kit Public Api automation scope in identity services.
#
Add-ScopeToIds -Scope $extensionKitAutomationScope -DisplayName "ExtensionKit Automation Scope"

#
#	Provision the Extension Kit Hibernation Service scopes in identity services.
#
Add-ScopeToIds -Scope $extensionKitHibernateScope -DisplayName "Extension Kit Hibernate scope for Hibernation Service"
Add-ScopeToIds -Scope $extensionKitAwakeScope -DisplayName "Extension Kit Awake scope for Hibernation Service"

#
#	Provision the Extension Kit Tenants API scopes.
#
Add-ScopeToIds -Scope $extensionKitTenantsReadScope -DisplayName "Extension Kit Tenants Read scope for Tenants Service"
Add-ScopeToIds -Scope $extensionKitTenantsManageScope -DisplayName "Extension Kit Tenants Manage scope for Tenants Service"

#
#	Provision the Extension Kit Marketplace API scope.
#
Add-ScopeToIds -Scope $extensionKitMarketplaceScope -DisplayName "Extension Kit Marketplace scope"

$claimsArray = @("u4mh-instance,$MessageHubInstanceName", "u4mh-sourcesystem,*", "u4mh-actor,*", "u4mh-tenant,*")

$identityCreationResult = Use-ExtensionKitIdentity -KeyVaultName $KeyVaultName -ClientId $extensionKitInternalClientId -ClientScopes "u4mh-accessprovider","u4mh-actor-relay","u4mh-director-relay", "u4mh-sourcesystem-publish", "u4mh-tenant-receive", $extensionKitApiScope, $accessManagementApiScope, $extensionKitHibernateScope, $extensionKitAwakeScope, $daPushScope, $extensionKitTenantsReadScope -Claims $claimsArray -ClientName "Extension Kit ($ExtensionKitServiceName) Internal Identity" -PrefixClaims $true
$identityCreationResult = Use-ExtensionKitIdentity -KeyVaultName $KeyVaultName -ClientId $extensionKitProvisionerClientId -ClientScopes "u4mh-accessprovider","u4mh-actor-relay","u4mh-director-relay","u4mh-sourcesystem-publish","u4mh-tenant-receive","u4mh-access-manage","u4mh-accesscontroller","u4mh-manager","u4mh-sourcesystem-manage", $accessManagementApiScope, "u4ds" -Claims $claimsArray -ClientName "Extension Kit ($ExtensionKitServiceName) Provisioner Identity" -PrefixClaims $true
$identityCreationResult = Use-ExtensionKitPortalIdentity -KeyVaultName $KeyVaultName -ClientId $extensionKitPortalClientId -ClientScopes "openid","offline_access",$extensionKitApiScope,"profile","email",$accessManagementApiScope,"u4mh-manager" -ClientName "Extension Kit ($ExtensionKitServiceName) Portal Identity" -PortalUrl $extensionKitPortalUrl
$identityCreationResult = Use-ExtensionKitIdentity -KeyVaultName $KeyVaultName -ClientId $extensionKitPowershellClientId -ClientScopes $extensionKitApiScope, $extensionKitAutomationScope, $accessManagementApiScope, $extensionKitMarketplaceScope -ClientName "Extension Kit ($ExtensionKitServiceName) PowerShell Admin Identity" -Claims "tenant,*", "SourceSystem,*"

Disconnect-IdentityServicesInstance

Write-Host "Provision U4IDS - Done"