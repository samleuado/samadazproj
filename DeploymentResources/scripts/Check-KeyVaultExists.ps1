param(
    [string]$keyVaultName
)

$exists = $null -ne (Get-AzKeyVault -VaultName $keyVaultName)

Write-Host "##vso[task.setvariable variable=keyVaultExists]$($exists.ToString().ToLower())"