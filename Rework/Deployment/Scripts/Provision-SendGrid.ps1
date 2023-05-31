Param(
    [Parameter(Mandatory=$true)][string]$KeyVaultName,
    [Parameter(Mandatory=$true)][string]$ApiKeyName,
    [Parameter(Mandatory=$true)][string]$SharedKeyVaultName,
    [Parameter(Mandatory=$true)][string]$ProvisioningApiKeyName
)

function GetApiKeyFromKeyVault{
    param(
        [Parameter(Mandatory=$true)][string]$keyVaultName,
        [Parameter(Mandatory=$true)][string]$apiKeyName
    )
    Write-Host "Get $($apiKeyName) SendGrid api from key vault"
    $apiKeyFromKeyVault = Get-AzureKeyVaultSecret -VaultName $keyVaultName -Name $apiKeyName -ErrorAction Stop
    $apiKeyFromKeyVault
}

function CreateApiKey{
    param(
        [Parameter(Mandatory=$true)][string]$provisioningMasterApiKey,
        [Parameter(Mandatory=$true)][string]$apiKeyName
    )
    $sendGridApiUrl = "https://api.sendgrid.com/v3"

    $bodyApiKey = @{
        name=$apiKeyName
        scopes=@("mail.send")
    }
    $bodyApiKeyJson = ConvertTo-json $bodyApiKey

    Write-Host "Generate new API Key from SendGrid api"
    $apiKeyResponse = Invoke-RestMethod -Method Post -Uri "$($sendGridApiUrl)/api_keys" -Headers @{ Authorization = "Bearer $($provisioningMasterApiKey)" } -ContentType application/json -Body $bodyApiKeyJson 
    $apiKeyResponse.api_key
}

function CopyKeyInKeyVault{
    param(
        [Parameter(Mandatory=$true)][string]$keyVaultName,
        [Parameter(Mandatory=$true)][string]$apiKeyName,
        [Parameter(Mandatory=$true)][string]$apiKeyValue
    )
    $apiKeyValueSecureString = ConvertTo-SecureString $apiKeyValue.ToString() -AsPlainText -Force
    Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name $apiKeyName -SecretValue $apiKeyValueSecureString -ErrorAction Stop | Out-Null
    Write-Host "Send Grid api key has been successfully copied to key vault"
}

Try {
    $fullApiKeyName = "$($ApiKeyName)-send-grid-api-key"
    $apiKeyFromKeyVault = GetApiKeyFromKeyVault -keyVaultName $KeyVaultName -apiKeyName $fullApiKeyName

    if ([string]::IsNullOrEmpty($apiKeyFromKeyVault)){
        $provisioningMasterApiKey = (GetApiKeyFromKeyVault -keyVaultName $SharedKeyVaultName -apiKeyName $ProvisioningApiKeyName).SecretValueText
        if ([string]::IsNullOrEmpty($provisioningMasterApiKey)){
            Write-Host "Provisioning master api key is null or empty"                 
        }else{
            $newApiKey = CreateApiKey -provisioningMasterApiKey $provisioningMasterApiKey -apiKeyName $ApiKeyName
            Write-Host "New SendGrid Api Key has been successfully created"
            CopyKeyInKeyVault -keyVaultName $KeyVaultName -apiKeyName $fullApiKeyName -apiKeyValue $newApiKey
        }            
    }
}
Catch 
{
    Write-Error "$_"
}