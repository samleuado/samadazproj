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
	[string]$AdminTenantName,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
	[string]$AdminTenantShortName,

    [Parameter()]
	[string]$AdminTenantLogoUrl,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
	[string]$AdminUserId,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
	[string]$AdminUserDisplayName,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
	[string]$AdminUserEmail,

	# The path where the script is running
    [Parameter()]
    [AllowEmptyString()]
	[string]$WorkingDirectory = ".\"
)

Write-Host "Provision U4AM"

Import-Module "$WorkingDirectory\Nuget-Utilities.psm1" -Force
Import-Module "$WorkingDirectory\AzureVault-Utilities.psm1" -Force

if ($null -eq (Get-AzContext).Account) 
{
    throw "No Azure RM Context available. Script will stop"
}


# Initialize some variables
$extensionKitPowershellClientId = "$ExtensionKitServiceName-powershell-admin"

$extensionKitPowershellClientSecret = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $extensionKitPowershellClientId

$accessManagementApiScope = "u4am-public-api"
$amUriWithApi = "$AmUrl/api/v1"


Install-NuGetPackage -NugetFeedName "U4PP" -NugetFeedUri "https://packages.u4pp.com/$NugetRepository/nuget/" -ModuleName "U4.AccessManagement.PowerShell" -MinimumVersion "1.0.3.4"


Connect-U4AM -IdsUri $IdsUrl -AmUri $amUriWithApi -ClientId $extensionKitPowershellClientId -ClientSecret $extensionKitPowershellClientSecret -AmScope $accessManagementApiScope

if ($null -eq (Get-U4AMSourceSystem -SourceSystemId $ExtensionKitSourceSystem)) 
{
    Write-Host "Adding SourceSystem $ExtensionKitSourceSystem"
    $sourceSystem = New-U4AMSourceSystem -SourceSystemId $ExtensionKitSourceSystem -Description "Extension Kit Source System ($ExtensionKitSourceSystem)" -Roles "Owner,Contributor,Reader"
    Add-U4AMSourceSystem $sourceSystem | Out-Null
} 
else 
{
    Write-Host "SourceSystem $ExtensionKitSourceSystem already exists"
}


if ($null -eq (Get-U4AMTenant -SourceSystemId $ExtensionKitSourceSystem -TenantId $AdminTenantId))
{
    Write-Host "Adding Tenant $AdminTenantId for SourceSystem $ExtensionKitSourceSystem"
    $tenant = New-U4AMTenant -SourceSystemId $ExtensionKitSourceSystem -TenantId $AdminTenantId -Name $AdminTenantName -ShortName $AdminTenantShortName -LogoUrl $AdminTenantLogoUrl -Status Active
    Add-U4AMTenant -SourceSystemId $ExtensionKitSourceSystem -Tenant $tenant | Out-Null
}
else 
{
    Write-Host "Tenant $AdminTenantId already exists for SourceSystem $ExtensionKitSourceSystem"
}


if ($null -eq (Get-U4AMUser -SourceSystemId $ExtensionKitSourceSystem -TenantId $AdminTenantId -UserId $AdminUserId)) 
{
    Write-Host "Adding User $AdminUserId for Tenant $AdminTenantId and SourceSystem $ExtensionKitSourceSystem"
    $user = New-U4AMUser -SourceSystemId $ExtensionKitSourceSystem -TenantId $AdminTenantId -UserId $AdminUserId -DisplayName $AdminUserDisplayName -Email $AdminUserEmail -Status Approved -Role "Owner" -HandledBy "devops\admin"
    Add-U4AMUser -SourceSystemId $ExtensionKitSourceSystem -User $user | Out-Null
} 
else
{
    Write-Host "User $AdminUserId for Tenant $AdminTenantId and SourceSystem $ExtensionKitSourceSystem already exists"
}

Disconnect-U4AM

Write-Host "Provision U4AM - Done"