[CmdletBinding()]
param(
 # The uri of the identity services endpoint, used to work with identity services and to obtain bearer tokens for calls to other micro-services.
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$IdsUrl,

    # The uri of the identity services endpoint, used to work with identity services and to obtain bearer tokens for calls to other micro-services.
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$AmUrl,

	# Name of a secure key vault which is available on the azure subscription under which this script is running.
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$KeyVaultName,

	# The Extension Kit Source System name to provision.
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionKitSourceSystem,

	# The Extension Kit service base name
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionKitServiceName,

    # the url domain to be used with the publicly reacheable services
	[Parameter()]
	[AllowEmptyString()]
	[string]$NugetRepository = "nuget",

    [Parameter()]
    [ValidateNotNullOrEmpty()]
	[string]$AdminTenantId,
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
	[string]$AdminUserId,

	# The path where the script is running
	[Parameter()]
	[AllowEmptyString()]
	[string]$WorkingDirectory = ".\"
)

Write-Host "Cleanup U4AM"

Import-Module "$WorkingDirectory\Nuget-Utilities.psm1" -Force
Import-Module "$WorkingDirectory\AzureVault-Utilities.psm1" -Force


if ($null -eq (Get-AzureRmContext).Account) 
{
    throw "No Azure RM Context available. Script will stop"
}


# Initialize some variables
$extensionKitPowershellClientId = "$ExtensionKitServiceName-powershell-admin"

$extensionKitPowershellClientSecret = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $extensionKitPowershellClientId
$accessManagementApiScope = "u4am-public-api"


Install-NuGetPackage -NugetFeedName "U4PP" -NugetFeedUri "https://packages.u4pp.com/$NugetRepository/nuget/" -ModuleName "U4.AccessManagement.PowerShell" -MinimumVersion "1.0.3.4"

Connect-U4AM -IdsUri $IdsUrl -AmUri $AmUrl -ClientId $extensionKitPowershellClientId -ClientSecret $extensionKitPowershellClientSecret -AmScope $accessManagementApiScope


if ($null -ne (Get-U4AMUser -SourceSystemId $ExtensionKitSourceSystem -TenantId $AdminTenantId -UserId $AdminUserId)) 
{
    Write-Host "Removing admin user $AdminUserId"
    Remove-U4AMUser -SourceSystemId $ExtensionKitSourceSystem -TenantId $AdminTenantId -UserId $AdminUserId  | Out-Null
}


if ($null -ne (Get-U4AMTenant -SourceSystemId $ExtensionKitSourceSystem -TenantId $AdminTenantId))
{
    Write-Host "Removing admin tenant $AdminTenantId"
    Remove-U4AMTenant -SourceSystemId $ExtensionKitSourceSystem -TenantId $AdminTenantId  | Out-Null
}

if ($null -ne (Get-U4AMSourceSystem -SourceSystemId $ExtensionKitSourceSystem)) 
{    
    Write-Host "Removing SourceSystem $ExtensionKitSourceSystem"
    Remove-U4AMSourceSystem  -SourceSystemId $ExtensionKitSourceSystem  | Out-Null
}

Disconnect-U4AM

Write-Host "Cleanup U4AM - Done"

