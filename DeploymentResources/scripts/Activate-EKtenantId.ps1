[CmdletBinding()]
param(
    # The uri of the identity services endpoint, used to work with identity services and to obtain bearer tokens for calls to other micro-services.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$IdsUrl,

    # The uri of the identity services endpoint, used to work with identity services and to obtain bearer tokens for calls to other micro-services.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$AmsUrl,
    
    # Name of Access Management scope
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$AmsApiScope,

    # Name of a secure key vault which is available on the azure subscription under which this script is running.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$KeyVaultName,

    # AMS client Id
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$clientName,

    # AMS secret Id
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$secretName,
    
    # The Extension Kit Source System name to provision.
    [Parameter()]
    [ValidateNotNullorEmpty()]
    [string]$SourceSystem,

    # The Extension Kit service base name
    [Parameter()]
    [ValidateNotNullorEmpty()]
    [string]$ServiceName,
    
    # The url domain to be used with the publicly reacheable services
    [Parameter()]
    [AllowEmptyString()]
    [string]$NugetRepository = "nuget",
    
    # Tenant ID of a new customer
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$TenantId,

    # Tenant name of a new customer to be displayed in the portal
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$TenantName,

    # Short name of the customer's Tenant ID
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$ShortName,

    # Custom Logo picture of the customer
    [Parameter()]
    [string]$LogoUrl,

    # The path where the script is running
    [Parameter()]
    [AllowEmptyString()]
    [string]$WorkingDirectory = ".\"
)

Write-Host "Tenant Activation"
#Write-Host "Get Secret from KeyVault $KeyVaultName for Client $SecretName"

Import-Module "$WorkingDirectory\Nuget-Utilities.psm1" -Force

Install-NuGetPackage -NugetFeedName "U4PP" -NugetFeedUri "https://packages.u4pp.com/$NugetRepository/nuget/" -ModuleName "U4.AccessManagement.PowerShell" -MinimumVersion "1.0.3.4"

Connect-U4AM -IdsUri $IdsUrl -AmUri $AmsUrl -ClientId $clientName -ClientSecret $secretName -AmScope $AmsApiScope


if ($null -eq (Get-U4AMTenant -SourceSystemId $SourceSystem -TenantId $TenantId)) {
    Write-Host "Adding Tenant $TenantId for SourceSystem $SourceSystem" -ForegroundColor Cyan
    $Tenant = New-U4AMTenant -SourceSystemId $SourceSystem -TenantId $TenantId -Name $TenantName -ShortName $ShortName -LogoUrl $LogoUrl -Status Active
    Add-U4AMTenant -SourceSystemId $SourceSystem -Tenant $Tenant | Out-Null
}
else {
    Write-Host "Tenant $TenantId already exists for SourceSystem $SourceSystem" -ForegroundColor Yellow
}

Disconnect-U4AM

Write-Host "Tenant Activation - Complited!" -ForegroundColor Cyan