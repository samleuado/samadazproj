
[CmdletBinding()]
param(
    # Name of a secure key vault which is available on the azure subscription under which this script is running.
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$KeyVaultName,

	# The Extension Kit Source System to deploy the extensions.
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionKitSourceSystem,

	# The Extension Kit service base name
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionKitServiceName,
	
	# The Extension Kit administration tenant.
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionKitAdminTenant,

	# The extension package Uri to deploy
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionPackageUri,

	# The extension type (Trigger | Action)
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionType,

	# The extension name
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionName,

	# The extension version
	[Parameter()]
	[ValidateNotNullorEmpty()]
	[string]$ExtensionVersion,

    # the url domain to be used with the publicly reacheable services
	[Parameter()]
	[AllowEmptyString()]
	[string]$CustomDomain = "azurewebsites.net",

    # the url domain to be used with the publicly reacheable services
	[Parameter()]
	[AllowEmptyString()]
	[string]$NugetRepository = "nuget",

	# The path where the script is running
	[Parameter()]
	[AllowEmptyString()]
	[string]$WorkingDirectory = ".\",

	# CustomServiceName
	[Parameter()]
	[AllowEmptyString()]
	[string]$CustomServiceName

)

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

Write-Host "Undeploy Extension - Started"

Import-Module "$WorkingDirectory\Nuget-Utilities.psm1" -Force
Import-Module "$WorkingDirectory\AzureVault-Utilities.psm1" -Force

if ($null -eq (Get-AzureRmContext).Account) 
{
    throw "No Azure RM Context available. Script will stop"
}

if([string]::IsNullOrEmpty($CustomServiceName)) 
{
	$CustomServiceName = $ExtensionKitServiceName
}

if ([string]::IsNullOrEmpty($CustomDomain)) {
	$CustomDomain =  "azurewebsites.net"
 }

$extensionKitApiUri = "https://$CustomServiceName-api.$CustomDomain"
$extensionKitHostUri = "https://$CustomServiceName-host.$CustomDomain"
$extensionKitPowershellClientId = "$ExtensionKitServiceName-powershell-admin"
$extensionKitPowershellClientSecret = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $extensionKitPowershellClientId

Install-NuGetPackage -NugetFeedName "U4PP" -NugetFeedUri "https://packages.u4pp.com/$NugetRepository/nuget/" -ModuleName "U4.ExtensionsKit.PowerShell"

Update-Module -Name U4.ExtensionsKit.PowerShell -Force

Write-Host "Connecting to EK environment $extensionKitApiUri and tenant $ExtensionKitAdminTenant with client $extensionKitPowershellClientId"

Connect-U4EK -ClientCredentialAuth -ClientId "$extensionKitPowershellClientId" -ClientSecret "$extensionKitPowershellClientSecret" -EkApiUri "$extensionKitApiUri" -Tenant "$ExtensionKitAdminTenant"

Write-Host "Connected"

Uninstall-U4EKEndpoint -Type $ExtensionType -Name "$ExtensionName"

Write-Host "Extension $ExtensionType-$ExtensionName uninstalled"

Write-Host "Deleting extension $ExtensionType-$ExtensionName..."

Delete-U4EKEndpoint -Type $ExtensionType -Name "$ExtensionName" -Version 1 -EkHostUri "$extensionKitHostUri"

Write-Host "Extension $ExtensionType-$ExtensionName deleted"
