[CmdletBinding()]
param(
    # Key Vault name where the secret is stored
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$KeyVaultName,

    # Name of the secret to be read
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$SecretName,

    # Name of the pipeline variable where the secret must be saved
    [Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$SecretVariableName,
	
	# The path where the script is running
    [Parameter()]
    [AllowEmptyString()]
	[string]$WorkingDirectory = ".\"
)

Write-Host "Get Secret from KeyVault $KeyVaultName for Client $SecretName"

Import-Module "$WorkingDirectory\Nuget-Utilities.psm1" -Force
Import-Module "$WorkingDirectory\AzureVault-Utilities.psm1" -Force

$clientSecret = Get-ClientSecretFromVault -KeyVaultName $KeyVaultName -NameWithVersion $SecretName -UseSuffix $false

Write-Host "##vso[task.setvariable variable=$SecretVariableName;issecret=true;]$clientSecret"