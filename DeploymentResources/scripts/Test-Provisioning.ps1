$IdsUrl = "https://u4ids-sandbox.u4pp.com"
$IdsAuthenticationMethod = "Bearer"
$IdsUsername = "u4ids-admin-client"
$IdsPassword = "sandbox"
$KeyVaultName = "u4ppsecrets"
$ExtensionKitInstanceName = "ht"
$ExtensionKitSourceSystem = "u4ek"
$ExtensionKitTenant = "u4ek-ht"
$UrlDomain = "azurewebsites.net"

$MessageHubInstanceName = "u4mh-dev"
$MessageHubInstanceUrlDomain = "azurewebsites.net"


$AmUrl = "https://u4-am-sandbox.azurewebsites.net/api/v1"
$adminTenantId = "u4pp-sandbox-directory"
$AdminTenantShortName = "u4pp-sandbox-directory"
$AdminTenantName = "ExtensionKit Admin Tenant"

$AdminUserId = "Hector Francisco Tortosa Martinez"
$AdminUserDisplayName = "Hector Tortosa"
$AdminUserEmail = "hector.tortosa@unit4.com"


$error.clear()
#Login-AzureRmAccount

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

.\Provision-U4IDS.ps1 -IdsUrl $IdsUrl -IdsAuthenticationMethod $IdsAuthenticationMethod  -IdsUsername $IdsUsername -IdsPassword $IdsPassword -KeyVaultName $KeyVaultName -ExtensionKitInstanceName $ExtensionKitInstanceName -ExtensionKitSourceSystem $ExtensionKitSourceSystem -UrlDomain $UrlDomain
.\Provision-U4MH.ps1 -IdsUrl $IdsUrl -KeyVaultName $KeyVaultName -ExtensionKitInstanceName $ExtensionKitInstanceName -ExtensionKitSourceSystem $ExtensionKitSourceSystem -ExtensionKitTenant $ExtensionKitTenant -MessageHubInstanceName $MessageHubInstanceName -MessageHubInstanceUrlDomain $MessageHubInstanceUrlDomain
.\Provision-U4AM.ps1 -IdsUrl $IdsUrl -AmUrl $AmUrl -KeyVaultName $KeyVaultName -ExtensionKitInstanceName $ExtensionKitInstanceName -ExtensionKitSourceSystem $ExtensionKitSourceSystem -AdminTenantId $adminTenantId -AdminTenantShortName $AdminTenantShortName -AdminTenantName $AdminTenantName -AdminUserId $AdminUserId -AdminUserDisplayName $AdminUserDisplayName -AdminUserEmail $AdminUserEmail


.\Cleanup-U4AM.ps1 -IdsUrl $IdsUrl -AmUrl $AmUrl -KeyVaultName $KeyVaultName -ExtensionKitInstanceName $ExtensionKitInstanceName -ExtensionKitSourceSystem $ExtensionKitSourceSystem -AdminTenantId $adminTenantId -AdminUserId $AdminUserId
.\Cleanup-U4MH.ps1 -IdsUrl $IdsUrl -KeyVaultName $KeyVaultName -ExtensionKitInstanceName $ExtensionKitInstanceName -ExtensionKitSourceSystem $ExtensionKitSourceSystem -ExtensionKitTenant $ExtensionKitTenant -MessageHubInstanceName $MessageHubInstanceName -MessageHubInstanceUrlDomain $MessageHubInstanceUrlDomain
.\Cleanup-U4IDS.ps1 -IdsUrl $IdsUrl -IdsAuthenticationMethod $IdsAuthenticationMethod  -IdsUsername $IdsUsername -IdsPassword $IdsPassword -KeyVaultName $KeyVaultName -ExtensionKitInstanceName $ExtensionKitInstanceName -ExtensionKitSourceSystem $ExtensionKitSourceSystem
