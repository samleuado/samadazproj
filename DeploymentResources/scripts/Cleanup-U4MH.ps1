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

	# The Extension Kit instance name to provision.
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionKitInstanceName,

	# The Extension Kit Source System name to provision.
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionKitSourceSystem,

	# The Extension Kit internal Tenant name to provision.
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
	[string]$NugetRepository = "nuget",

	# The path where the script is running
	[Parameter()]
	[string]$WorkingDirectory = ".\"

)

function Remove-ExtensionKitMessageHubResources
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

    Write-Host "Cleanup U4MH - Done"


	Write-Host "Connection to message hub instance $MessageHubInstanceName ... "
	Connect-U4MH -Authority "$($IdsUrl)/identity" -ManagementUri $MessageHubManagementUrl -AccessControlUri $MessageHubAccessControlUrl -ClientId $ProvisionerClientId -Secret $ProvisionerClientSecret

    Write-Host "Checking to see if source system $SourceSystem has been provisioned ..."

	($existingSourceSystem = Get-U4MHSourceSystem -Name $SourceSystem -ErrorAction SilentlyContinue) | Out-Null
	
	if ($existingSourceSystem)
	{
        Write-Host "Source system $SourceSystem has been provisioned, we will need to remove it ..."

		$receiversToRemove = Get-U4MHReceiver -SourceSystem $SourceSystem
		
		foreach($receiver in $receiversToRemove)
		{ 
            Write-Host "Removing receiver for $($receiver.AppId)" 
            Remove-U4MHReceiver -SourceSystem $SourceSystem -AppId $receiver.AppId -Force
		}
		
		$actorsToRemove = Get-U4MHActor -SourceSystem $SourceSystem
		
		foreach($actor in $actorsToRemove)
		{ 
            Write-Host "Removing Actor $($actor.AppId)" 
            Remove-U4MHActor -SourceSystem $SourceSystem -AppId $actor.AppId -Force
		}
		
		$directorsToRemove = Get-U4MHDirector -SourceSystem $SourceSystem
		
		foreach($director in $directorsToRemove)
		{ 
            Write-Host "Removing Director $($director.AppId)" 
            Remove-U4MHDirector -SourceSystem $SourceSystem -AppId $director.AppId -Force
		}
		
        Write-Host "Removing source system $SourceSystem ..."

        #Remove-U4MHIdentity -Identity $ProvisionerClientId  -Force
        #Remove-U4MHIdentity -Identity $InternalClientId  -Force
        Remove-U4MHResource -Type SourceSystem -Name $SourceSystem
        Remove-U4MHSourceSystem -Name $SourceSystem -Force
    }
	
	Write-Host "Disconnecting from message hub instance $MessageHubInstanceName ..."
	Disconnect-U4MH
}



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

$extensionKitProvisionerClientSecret = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $extensionKitProvisionerClientId

Install-NuGetPackage -NugetFeedName "U4PP" -NugetFeedUri "https://packages.u4pp.com/$NugetRepository/nuget/" -ModuleName "U4.MessageHub.PowerShell" -MinimumVersion "1.2.17243.2"

Remove-ExtensionKitMessageHubResources -ProvisionerClientId $extensionKitProvisionerClientId -ProvisionerClientSecret $extensionKitProvisionerClientSecret -InternalClientId $extensionKitInternalClientId -MessageHubManagementUrl $messageHubManagementUrl -MessageHubAccessControlUrl $messageHubAccessControlUrl -SourceSystem $ExtensionKitSourceSystem -Tenant $ExtensionKitTenant


Write-Host "Cleanup U4MH - Done"