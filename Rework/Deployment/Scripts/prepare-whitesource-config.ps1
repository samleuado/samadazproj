[CmdletBinding()]
param(
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$InputFilePath,

	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$OutputFilePath,

	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$ProductName,

	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$UserKey,

	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$ApiKey
)

$content = Get-Content -Path $InputFilePath
$content = $content.replace("!__ProductName__!", $ProductName)
$content = $content.replace("!__UserKey__!", $UserKey)
$content = $content.replace("!__ApiKey__!", $ApiKey)

Set-Content -Path $OutputFilePath -Value $content