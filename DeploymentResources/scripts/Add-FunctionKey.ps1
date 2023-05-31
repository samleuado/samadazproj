Param(
    [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
    [string] [Parameter(Mandatory=$true)] $FunctionAppName,
    [string] [Parameter(Mandatory=$true)] $KeyName,
    [string] [Parameter(Mandatory=$true)] $KeyVaultName,
    [string] [Parameter(Mandatory=$true)] $ExtensionKitServiceName,
    [string] [Parameter()] $WorkingDirectory = ".\"          
)

$apiBaseUrl = "https://$FunctionAppName.scm.azurewebsites.net/api"
$siteBaseUrl = "https://$FunctionAppName.azurewebsites.net"
$resourceType = "Microsoft.Web/sites/config"
$resourceName = "$FunctionAppName/publishingcredentials"
$secretName = "$ExtensionKitServiceName-azure-function-secret"

Try 
{
    Write-Host "Get the publishing credentials"
    $publishingCredentials = Invoke-AzResourceAction -ResourceGroupName $resourceGroupName -ResourceType $resourceType -ResourceName $resourceName -Action list -ApiVersion 2015-08-01 -Force

    Write-Host "Generate the Kudu API Authorisation Token"
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $publishingCredentials.Properties.PublishingUserName, $publishingCredentials.Properties.PublishingPassword)))

    Write-Host "Call Kudu /api/functions/admin/token to get a JWT that can be used with the Functions Key API"
    $jwt = Invoke-RestMethod -Uri "$apiBaseUrl/functions/admin/token" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method GET

    Import-Module "$WorkingDirectory\Nuget-Utilities.psm1" -Force
    Import-Module "$WorkingDirectory\AzureVault-Utilities.psm1" -Force

    Write-Host "Get Secret from KeyVault $KeyVaultName for Client $SecretName"
    $azureFunctionSecret = Get-ClientSecretFromVaultAz -KeyVaultName $KeyVaultName -NameWithVersion $SecretName -UseSuffix $false

    Write-Host "Creates or updates an host key at the specified resource with the retrieved secret value"
    $body = @{
        "name" = "$keyName"
        "value" = "$azureFunctionSecret"
        } | ConvertTo-Json;

    $mynewkey = (Invoke-RestMethod -ContentType "application/json" -Uri "$siteBaseUrl/admin/host/keys/$keyname" -Headers @{Authorization=("Bearer {0}" -f $jwt)} -Method PUT -Body $body).value

    Write-Host "##vso[task.setvariable variable=$keyname;issecret=true;]$mynewkey"
}
Catch 
{
    Write-Error "$_"
}