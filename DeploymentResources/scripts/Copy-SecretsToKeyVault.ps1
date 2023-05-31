param(

    [string]$keyVaultName,

    [string]$certificateKeyVaultName,
    [string]$certificatePasswordName,
    [string]$certificateSecretName,

    [string]$idsKeyVaultName,
    [string]$idsUsername,
    [string]$idsPassword,

    [string]$ExtensionKitServiceName
)

function CreateKeyVaultSecretIfNotExist {
    param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$keyName
    )

    $secret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $keyName -ErrorAction Stop

    if ([string]::IsNullOrEmpty($secret.Name) -or [string]::IsNullOrEmpty($secret.SecretValue)) {
        $secretValue = New-Guid
        $secureSecret = ConvertTo-SecureString $secretValue.ToString() -AsPlainText -Force

        Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $keyName -SecretValue $secureSecret -ErrorAction Stop | Out-Null
    }
}

if($keyVaultName -ne $idsKeyVaultName) {
    
    if ($null -eq (Get-AzContext).Account) 
    {
        throw "No Azure RM Context available. Script will stop"
    }
    
    $extensionKitInternalClientSecretName = "$ExtensionKitServiceName-internal-secret"   
    $extensionKitProvisionerSecretName = "$ExtensionKitServiceName-provisioner-secret"   
    $extensionKitPortalSecretName = "$ExtensionKitServiceName-portal-secret"   
    $extensionKitPowershellSecretName = "$ExtensionKitServiceName-powershell-admin-secret"   

    Try {

        $secrets = @()
        Write-Verbose "Getting Secrets ..."
        $secrets += Get-AzKeyVaultSecret -VaultName $certificateKeyVaultName -Name $certificatePasswordName -ErrorAction Stop
        $secrets += Get-AzKeyVaultSecret -VaultName $certificateKeyVaultName -Name $certificateSecretName -ErrorAction Stop
        $secrets += Get-AzKeyVaultSecret -VaultName $idsKeyVaultName -Name $idsUsername -ErrorAction Stop
        $secrets += Get-AzKeyVaultSecret -VaultName $idsKeyVaultName -Name $idsPassword -ErrorAction Stop

        # Copy secrets that are already created in IDS in incremental deployments
        $secrets += Get-AzKeyVaultSecret -VaultName $idsKeyVaultName -Name $extensionKitInternalClientSecretName -ErrorAction Stop
        $secrets += Get-AzKeyVaultSecret -VaultName $idsKeyVaultName -Name $extensionKitProvisionerSecretName -ErrorAction Stop
        $secrets += Get-AzKeyVaultSecret -VaultName $idsKeyVaultName -Name $extensionKitPortalSecretName -ErrorAction Stop
        $secrets += Get-AzKeyVaultSecret -VaultName $idsKeyVaultName -Name $extensionKitPowershellSecretName -ErrorAction Stop
    } 
    Catch {
        Throw "Getting secrets failed: $_"
    }
    
    foreach ($secret in $secrets) {

        Try {
            if (-not [string]::IsNullOrEmpty($secret.Name) -and -not [string]::IsNullOrEmpty($secret.SecretValue)) {
                Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $secret.Name -SecretValue $secret.SecretValue -ErrorAction Stop | Out-Null
                Write-Verbose "Secret $($secret.Name) has been successfully copied to $keyVaultName"
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
