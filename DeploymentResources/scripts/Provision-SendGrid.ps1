Param(
    [Parameter(Mandatory=$true)][string]$keyVaultName,
    [Parameter(Mandatory=$true)][string]$apiKeyName,
    [Parameter(Mandatory=$true)][string]$shareKeyVaultName,
    [Parameter(Mandatory=$true)][string]$provisioningApiKeyName
)

function GetApiKeyFromKeyVault{
    param(
        [Parameter(Mandatory=$true)][string]$keyVaultName,
        [Parameter(Mandatory=$true)][string]$apiKeyName
    )
    Write-Host "Get $($apiKeyName) SendGrid api from key vault"
    $apiKeyFromKeyVault = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $apiKeyName -AsPlainText -ErrorAction Stop
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
    Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $apiKeyName -SecretValue $apiKeyValueSecureString -ErrorAction Stop | Out-Null
    Write-Host "Send Grid api key has been successfully copied to key vault"
}

Try {
    $fullApiKeyName = "$($apiKeyName)-send-grid-api-key"
    $apiKeyFromKeyVault = GetApiKeyFromKeyVault -keyVaultName $keyVaultName -apiKeyName $fullApiKeyName

    if ([string]::IsNullOrEmpty($apiKeyFromKeyVault)){
        $provisioningMasterApiKey = (GetApiKeyFromKeyVault -keyVaultName $shareKeyVaultName -apiKeyName $provisioningApiKeyName).SecretValueText
        if ([string]::IsNullOrEmpty($provisioningMasterApiKey)){
            Write-Host "Provisioning master api key is null or empty"                 
        }else{
            $newApiKey = CreateApiKey -provisioningMasterApiKey $provisioningMasterApiKey -apiKeyName $apiKeyName
            Write-Host "New SendGrid Api Key has been successfully created"
            CopyKeyInKeyVault -keyVaultName $keyVaultName -apiKeyName $fullApiKeyName -apiKeyValue $newApiKey
        }            
    }
}
Catch 
{
    Write-Error "$_"
}