[CmdletBinding()]
param(
    # The uri of the identity services endpoint, used to work with identity services and to obtain bearer tokens for calls to other micro-services.
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$IdsUrl,

	# Name of a secure key vault which is available on the azure subscription under which this script is running.
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$KeyVaultName,

	# The Extension Kit Source System name to provision.
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionKitSourceSystem,

	# The Extension Kit internal tenant name to provision.
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionKitTenant,

	# The Extension Kit service base name
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionKitServiceName,

    # The name of the message hub instance against which the Extension Kit instance will run.
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$MessageHubInstanceName,

    # The Url Domain used as the default in the Extension Kit instance, and other micro-services.
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$MessageHubInstanceUrlDomain,

    # the url domain to be used with the publicly reacheable services
	[Parameter()]
	[AllowEmptyString()]
	[string]$NugetRepository = "nuget",

	# The path where the script is running
	[Parameter()]
	[AllowEmptyString()]
	[string]$WorkingDirectory = ".\"
)

function Provision-ExtensionKitMessageHubSourceSystem
{
	[CmdletBinding()]
	param
	(
		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$ProvisionerClientId,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$InternalClientId,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$SourceSystem,
		
		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$ProvisionerClientSecret,
		
		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$MessageHubManagementUrl,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$MessageHubAccessControlUrl
	)

	Write-Host "Checking to see if source system $SourceSystem has been provisioned ..."

	($existingSourceSystem = Get-U4MHSourceSystem -Name $SourceSystem -ErrorAction SilentlyContinue) | Out-Null

	if (!$existingSourceSystem)
	{
		Write-Host "Source system $SourceSystem does not exist and will now be provisioned ..."
		$mhResource = Get-U4MHResource -Type SourceSystem -Name $SourceSystem -ErrorAction SilentlyContinue| Out-Null
		if ($null -ne $mhResource) {
			Add-U4MHResource -Type SourceSystem -Name $SourceSystem
		}
		Set-U4MHIdentity -Identity $ProvisionerClientId -Role Act,Manage,ManageAccess,Receive,Send,Direct -Description "Extension Kit ($ExtensionKitSourceSystem) Provisioner Identity" | Out-Null
		Set-U4MHIdentity -Identity $InternalClientId -Role Act,Receive,Send,Direct -Description "Extension Kit ($ExtensionKitSourceSystem) Internal Identity" | Out-Null
			
		Grant-U4MHIdentityResource -Identity $ProvisionerClientId -SourceSystem "*" | Out-Null
		Grant-U4MHIdentityResource -Identity $ProvisionerClientId -Actor "*" | Out-Null
		Grant-U4MHIdentityResource -Identity $ProvisionerClientId -Tenant "*" | Out-Null
		Grant-U4MHIdentityResource -Identity $InternalClientId -SourceSystem "*" | Out-Null
		Grant-U4MHIdentityResource -Identity $InternalClientId -Actor "*" | Out-Null
		Grant-U4MHIdentityResource -Identity $InternalClientId -Tenant "*" | Out-Null

		Write-Host "Disconnecting MessageHub"
		Disconnect-U4MH
		Write-Host "Reconnecting MessageHub"
		Connect-U4MH -Authority "$($IdsUrl)/identity" -ManagementUri $MessageHubManagementUrl -AccessControlUri $MessageHubAccessControlUrl -ClientId $ProvisionerClientId -Secret $ProvisionerClientSecret            
		Add-U4MHSourceSystem -Name $SourceSystem
	}
	else
	{
		Write-Host "Source system $SourceSystem exists, no provisioning required ..."
	}
}

function Provision-ExtensionKitMessageHubTenant
{
	[CmdletBinding()]
	param
	(
		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$Tenant
	)

	Write-Host "Checking to see if tenant $Tenant has been provisioned ..."

	($existingTenant = Get-U4MHResource -Name $Tenant -Type Tenant -ErrorAction SilentlyContinue) | Out-Null

	if (!$existingTenant)
	{
		Write-Host "Tenant $Tenant does not exist and will now be provisioned ..."

		Add-U4MHResource -Type Tenant -Name $Tenant | Out-Null
	}
	else
	{
		Write-Host "Tenant $Tenant exists, no provisioning required ..."
	}
}

function Provision-ExtensionKitMessageHubReceiver
{
	[CmdletBinding()]
	param
	(
		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$SourceSystem,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$PublisherSourceSystem,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$Tenant,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$Receiver,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$EventName,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$Version
	)

	Write-Host "Checking to see if receiver $Receiver for source system $SourceSystem has been provisioned ..."

	($existingReceiver = Get-U4MHReceiver -SourceSystem $SourceSystem -AppId $Receiver -ErrorAction SilentlyContinue) | Out-Null

	($existingEventType = Get-U4MHEventType -Filter $EventName -Version $Version -SourceSystem $PublisherSourceSystem -Type EventMessage -ErrorAction SilentlyContinue) | Out-Null

	($existingSubscription = Get-U4MHTenantSubscriptionEventType -SourceSystem $SourceSystem -AppId $Receiver -FromSourceSystem $PublisherSourceSystem -Tenant $Tenant -Type EventMessage -EventName $EventName -Version $Version) | Out-Null

	if ($existingReceiver)
	{
		Write-Host "Receiver $Receiver for source system $SourceSystem exists, no provisioning required."
	}
	else 
	{
		Write-Host "Receiver $Receiver for source system $SourceSystem does not exist and will now be provisioned ..."

		Add-U4MHReceiver -SourceSystem $SourceSystem -AppId $Receiver | Out-Null
	}

	if ($existingEventType)
	{
		if($existingSubscription)
		{
			Write-Host "Subscription on receiver $Receiver to event $EventName ($EventVersion) exists, no provisioning required."
		}
		else 
		{
			Write-Host "Subscription on receiver $Receiver to event $EventName ($EventVersion) does not exist and will now be provisioned ..."

			Add-U4MHTenantSubscriptionEventType -SourceSystem $SourceSystem -AppId $Receiver -FromSourceSystem $PublisherSourceSystem -Tenant $Tenant -Type EventMessage -EventName $EventName -Version $Version | Out-Null	
		}
	}
	else 
	{
		Write-Host "Event Type $EventName for source system $PublisherSourceSystem does not exist, receiver cannot be created."
	}
}

function Provision-ExtensionKitMessageHubDirector
{
	[CmdletBinding()]
	param
	(
		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$SourceSystem,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$Director
	)

	Write-Host "Checking to see if director $Director for source system $SourceSystem has been provisioned ..."
	($existingDirector = Get-U4MHDirector -SourceSystem $SourceSystem -AppId $Director -ErrorAction SilentlyContinue) | Out-Null

	if (!$existingDirector)
	{
		Write-Host "Director $Director for source system $SourceSystem does not exist and will now be provisioned ..."
		Add-U4MHDirector -SourceSystem $SourceSystem -AppId $Director | Out-Null
	}
	else
	{
		Write-Host "Director $Director for source system $SourceSystem exists, no provisioning required ..."
	}
}

function Provision-ExtensionKitMessageHubResources
{

	[CmdletBinding()]
	param
	(
		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$ProvisionerClientId,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$ProvisionerClientSecret,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$InternalClientId,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$InternalClientSecret,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$MessageHubManagementUrl,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$MessageHubAccessControlUrl,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$SourceSystem,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$Tenant
	)

	Write-Host "Connection to Message Hub instance $MessageHubInstanceName with ClientId $ProvisionerClientId..."
	Connect-U4MH -Authority "$($IdsUrl)/identity" -ManagementUri $MessageHubManagementUrl -AccessControlUri $AccessControlUri -ClientId $ProvisionerClientId -Secret $ProvisionerClientSecret

	Write-Host "Provisioning Source System $SourceSystem..."
	Provision-ExtensionKitMessageHubSourceSystem -ProvisionerClientId $ProvisionerClientId -InternalClientId $InternalClientId -SourceSystem $SourceSystem -ProvisionerClientSecret $ProvisionerClientSecret -MessageHubManagementUrl $MessageHubManagementUrl -MessageHubAccessControlUrl $MessageHubAccessControlUrl

	Write-Host "Provisioning Tenant $Tenant..."
	Provision-ExtensionKitMessageHubTenant -Tenant $Tenant

	Write-Host "Provisioning Tenant Activation receiver ta-receiver (2.0)..."
	Provision-ExtensionKitMessageHubReceiver -SourceSystem $SourceSystem -Receiver "ta-receiver" -PublisherSourceSystem "u4tas" -Tenant "*" -EventName "tenantactivationprocessevent" -Version "2.0"
	
	Write-Host "Provisioning MH Director Action director ek-action-direct..."
	Provision-ExtensionKitMessageHubDirector -SourceSystem $SourceSystem -Director "ek-action-direct"

	Write-Host "Disconnecting from message hub instance $MessageHubInstanceName ..."
	Disconnect-U4MH

}

Write-Host "Provision U4MH"

Import-Module "$WorkingDirectory\Nuget-Utilities.psm1" -Force
Import-Module "$WorkingDirectory\AzureVault-Utilities.psm1" -Force

if ($null -eq (Get-AzureRmContext).Account) 
{
    throw "No Azure RM Context available. Script will stop"
}

# Initialize some variables
$extensionKitInternalClientId = "$ExtensionKitServiceName-internal"
$extensionKitProvisionerClientId = "$ExtensionKitServiceName-provisioner"

$messageHubAccessControlUrl = "https://$MessageHubInstanceName-accesscontroller.$MessageHubInstanceUrlDomain"
$messageHubManagementUrl = "https://$MessageHubInstanceName-manager.$MessageHubInstanceUrlDomain"

$extensionKitInternalClientSecret = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $extensionKitInternalClientId
$extensionKitProvisionerClientSecret = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $extensionKitProvisionerClientId

Install-NuGetPackage -NugetFeedName "U4PP" -NugetFeedUri "https://packages.u4pp.com/$NugetRepository/nuget/" -ModuleName "U4.MessageHub.PowerShell" -MinimumVersion "1.2.17243.2"

Provision-ExtensionKitMessageHubResources -ProvisionerClientId $extensionKitProvisionerClientId -ProvisionerClientSecret $extensionKitProvisionerClientSecret -InternalClientId $extensionKitInternalClientId -InternalClientSecret $extensionKitInternalClientSecret -MessageHubManagementUrl $messageHubManagementUrl -MessageHubAccessControlUrl $messageHubAccessControlUrl -SourceSystem $ExtensionKitSourceSystem -Tenant $ExtensionKitTenant

Write-Host "Provision U4MH - Done"