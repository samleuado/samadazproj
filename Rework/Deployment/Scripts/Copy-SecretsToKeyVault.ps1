param(

    [string]$KeyVaultName,

    [string]$CertificateKeyVaultName,
    [string]$CertificatePasswordName,
    [string]$CertificateSecretName,

    [string]$IdsKeyVaultName,
    [string]$IdsUsername,
    [string]$IdsPassword,

    [string]$ExtensionKitServiceName,
    [string]$AzureFunctionKeySecretName
)

function CreateKeyVaultSecretIfNotExist {
    param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$keyName
    )

    $secret = Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $keyName -ErrorAction Stop

    if ([string]::IsNullOrEmpty($secret.Name) -or [string]::IsNullOrEmpty($secret.SecretValue)) {
        $secretValue = New-Guid
        $secureSecret = ConvertTo-SecureString $secretValue.ToString() -AsPlainText -Force

        Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $keyName -SecretValue $secureSecret -ErrorAction Stop | Out-Null
    }
}

if($KeyVaultName -ne $IdsKeyVaultName) {
    
    if ($null -eq (Get-AzureRmContext).Account) 
    {
        throw "No Azure RM Context available. Script will stop"
    }
    
    $extensionKitInternalClientSecretName = "$ExtensionKitServiceName-internal-secret"
    $extensionKitDiscoClientSecretName = "$ExtensionKitServiceName-disco-secret"
    $extensionKitProvisionerSecretName = "$ExtensionKitServiceName-provisioner-secret"   
    $extensionKitPortalSecretName = "$ExtensionKitServiceName-portal-secret"   
    $extensionKitPowershellSecretName = "$ExtensionKitServiceName-powershell-admin-secret"

    Try {

        $secrets = @()
        Write-Verbose "Getting Secrets ..."
        $secrets += Get-AzureKeyVaultSecret -VaultName $CertificateKeyVaultName -Name $CertificatePasswordName -ErrorAction Stop
        $secrets += Get-AzureKeyVaultSecret -VaultName $CertificateKeyVaultName -Name $CertificateSecretName -ErrorAction Stop
        $secrets += Get-AzureKeyVaultSecret -VaultName $IdsKeyVaultName -Name $IdsUsername -ErrorAction Stop
        $secrets += Get-AzureKeyVaultSecret -VaultName $IdsKeyVaultName -Name $IdsPassword -ErrorAction Stop

        # Copy secrets that are already created in IDS in incremental deployments
        $secrets += Get-AzureKeyVaultSecret -VaultName $IdsKeyVaultName -Name $extensionKitInternalClientSecretName -ErrorAction Stop
        $secrets += Get-AzureKeyVaultSecret -VaultName $IdsKeyVaultName -Name $extensionKitDiscoClientSecretName -ErrorAction Stop
        $secrets += Get-AzureKeyVaultSecret -VaultName $IdsKeyVaultName -Name $extensionKitProvisionerSecretName -ErrorAction Stop
        $secrets += Get-AzureKeyVaultSecret -VaultName $IdsKeyVaultName -Name $extensionKitPortalSecretName -ErrorAction Stop
        $secrets += Get-AzureKeyVaultSecret -VaultName $IdsKeyVaultName -Name $extensionKitPowershellSecretName -ErrorAction Stop
    } 
    Catch {
        Throw "Getting secrets failed: $_"
    }
    
    foreach ($secret in $secrets) {

        Try {
            if (-not [string]::IsNullOrEmpty($secret.Name) -and -not [string]::IsNullOrEmpty($secret.SecretValue)) {
                Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $secret.Name -SecretValue $secret.SecretValue -ErrorAction Stop
                Write-Verbose "Secret $($secret.Name) has been successfully copied to $KeyVaultName"
            }else {
                Write-Verbose "Skipping secret as it's empty" 
            }
        }
        Catch {
            
            Throw "Copying secrets failed: $_"
        }
    }

    # Generate Event Grid Internal Key if it doesn't exist on KeyVault
    CreateKeyVaultSecretIfNotExist -keyName "$ExtensionKitServiceName-internal-eventgrid-secret"

    # Generate Azure Function Host Key if it doesn't exist on KeyVault
    CreateKeyVaultSecretIfNotExist -keyName "$ExtensionKitServiceName-azure-function-secret"
}
