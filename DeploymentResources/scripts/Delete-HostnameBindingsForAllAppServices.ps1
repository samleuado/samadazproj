[CmdletBinding()]
param(
    # Name of the resource group where the deletion will be performed.
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$ResourceGroupName
)

Get-AzWebApp -ResourceGroupName $ResourceGroupName | ForEach-Object -Process {
	$sslBindings = Get-AzWebAppSSLBinding -WebApp $_
	$u4ppBinding = $sslBindings | Where-Object { $_ -ne $null -and $_.Name -ne $null -and $_.Name -match "u4pp.com" }
	if (![string]::IsNullOrEmpty($u4ppBinding.Name)) {
		Write-Host "Deleting hostbinding for: $u4ppBinding.Name"
		Remove-AzWebAppSSLBinding -WebApp $_ -Name $u4ppBinding.Name -Force -DeleteCertificate $False
		Write-Host "Deleted hostbinding for: $u4ppBinding.Name"
	}
}