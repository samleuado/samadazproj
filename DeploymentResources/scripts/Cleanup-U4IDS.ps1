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

	# The Extension Kit service base name
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionKitServiceName,
	
	[Parameter()]
	[AllowEmptyString()]
	[string]$NugetRepository = "nuget",

	# The path where the script is running
	[Parameter()]
	[AllowEmptyString()]
	[string]$WorkingDirectory = ".\"
)

Write-Host "Cleanup U4IDS - Started"

$extensionKitInternalClientId = "$ExtensionKitServiceName-internal"
$extensionKitProvisionerClientId = "$ExtensionKitServiceName-provisioner"
$extensionKitPortalClientId = "$ExtensionKitServiceName-portal"
$extensionKitPowershellClientId = "$ExtensionKitServiceName-powershell-admin"

Import-Module "$WorkingDirectory\Nuget-Utilities.psm1" -Force
Import-Module "$WorkingDirectory\AzureVault-Utilities.psm1" -Force
Import-Module "$WorkingDirectory\U4IDS-Utilities.psm1" -Force

Install-NuGetPackage -NugetFeedName "U4PP" -NugetFeedUri "https://packages.u4pp.com/$NugetRepository/nuget/" -ModuleName "U4.IdentityServices.PowerShell" -MinimumVersion "1.0.0.0"

if ($null -eq (Get-AzureRmContext).Account) 
{
    throw "No Azure RM Context available. Script will stop"
}

Connect-IdentityServicesInstance -KeyVaultName $KeyVaultName -IdsUrl $IdsUrl -IdsAuthenticationMethod $IdsAuthenticationMethod -IdsUsername $IdsUsername -IdsPassword $IdsPassword
Write-Host "Connected"

Write-Host "Removing clients from identity services ..."

Remove-U4IDSClient -ClientId $extensionKitProvisionerClientId -ErrorAction SilentlyContinue
Remove-U4IDSClient -ClientId $extensionKitInternalClientId -ErrorAction SilentlyContinue
Remove-U4IDSClient -ClientId $extensionKitPortalClientId -ErrorAction SilentlyContinue
Remove-U4IDSClient -ClientId $extensionKitPowershellClientId -ErrorAction SilentlyContinue

Write-Host "Removing clients secrets from Azure Vault"

Remove-ClientSecretFromVault -KeyVaultName $KeyVaultName -ClientId $extensionKitProvisionerClientId
Remove-ClientSecretFromVault -KeyVaultName $KeyVaultName -ClientId $extensionKitInternalClientId
Remove-ClientSecretFromVault -KeyVaultName $KeyVaultName -ClientId $extensionKitPortalClientId
Remove-ClientSecretFromVault -KeyVaultName $KeyVaultName -ClientId $extensionKitPowershellClientId

Disconnect-IdentityServicesInstance

Write-Host "Cleanup U4IDS - Done"
