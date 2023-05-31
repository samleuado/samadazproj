## Get Secret that is stored from Azure Vault
function Get-ClientSecretFromVault {
	[CmdletBinding()]
	param(

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$KeyVaultName,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$NameWithVersion,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[bool]$UseSuffix = $true
	)

	Write-Host "Getting value from KeyVault $KeyVaultName with name $NameWithVersion"

	$nameAndVersion = $NameWithVersion.Split('/');
	
	if ($nameAndVersion.length -eq 2) {
		Write-Host "Getting with version"

		$name = $nameAndVersion[0]
		$version = $nameAndVersion[1]

		if ($UseSuffix) {
			Write-Host "Using -secret suffix"
			$name = "$name-secret"
		}
	
		Write-Host "Getting secret $name with version $version from vault $KeyVaultName"
	    (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $name -Version $version -AsPlainText)
	} 
	else {
		$name = $NameWithVersion

		if ($useSuffix) {
			Write-Host "Using -secret suffix"
			$name = "$NameWithVersion-secret"
		}

		Write-Host "Getting secret $name without version from vault $KeyVaultName"
        (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $name -AsPlainText)
	}
}

## Get Secret that is stored from Azure Vault - using Az function
function Get-ClientSecretFromVaultAz {
	[CmdletBinding()]
	param(

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$KeyVaultName,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$NameWithVersion,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[bool]$UseSuffix = $true
	)

	Write-Host "Getting value from KeyVault $KeyVaultName with name $NameWithVersion"

	$nameAndVersion = $NameWithVersion.Split('/');
	
	if ($nameAndVersion.length -eq 2) {
		Write-Host "Getting with version"

		$name = $nameAndVersion[0]
		$version = $nameAndVersion[1]

		if ($UseSuffix) {
			Write-Host "Using -secret suffix"
			$name = "$name-secret"
		}
	
		Write-Host "Getting secret $name with version $version from vault $KeyVaultName"
		Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $name -Version $version -AsPlainText
	} 
	else {
		$name = $NameWithVersion

		if ($useSuffix) {
			Write-Host "Using -secret suffix"
			$name = "$NameWithVersion-secret"
		}

		Write-Host "Getting secret $name without version from vault $KeyVaultName"
		Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $name -AsPlainText
	}
}

function Write-ClientSecretIntoVault {
	[CmdletBinding()]
	param(
		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$KeyVaultName,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		$ClientId,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		$ClientSecret,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[bool]$UseSuffix = $true
	)

	$name = $ClientId
	if ($UseSuffix) {
		Write-Host "Using -secret suffix"
		$name = "$ClientId-secret"
	}

	$secretKeyValue = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force

	Write-Host "Writing secret $name into vault $KeyVaultName"
	Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $name -SecretValue $secretKeyValue | Out-Null
}

function Remove-ClientSecretFromVault {
	[CmdletBinding()]
	param(

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$KeyVaultName,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$ClientId,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[bool]$UseSuffix = $true
	)

	$name = $ClientId
	if ($useSuffix) {
		Write-Host "Using -secret suffix"
		$name = "$ClientId-secret"
	}

	Write-Host "Removing secret $name from vault $KeyVaultName"
	Remove-AzKeyVaultSecret -VaultName $KeyVaultName -Name $name -Force -Confirm:$False -ErrorAction SilentlyContinue
}
