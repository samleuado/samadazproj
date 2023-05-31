Param (
    [string]$CustomServiceName,
    [string]$CustomDomain,
    [string]$idsUri,
    [string]$idsUsername,
    [string]$idsPassword,
    [string]$KeyVaultName,
    [string]$ClientID,
    # the url domain to be used with the publicly reacheable services
	[Parameter()]
	[AllowEmptyString()]
    [string]$NugetRepository = "nuget",
    # The path where the script is running
	[Parameter()]
	[AllowEmptyString()]
	[string]$WorkingDirectory = ".\"

)

Import-Module "$WorkingDirectory\Nuget-Utilities.psm1" -Force

Install-NuGetPackage -NugetFeedName "U4PP" -NugetFeedUri "https://packages.u4pp.com/$NugetRepository/nuget/" -ModuleName "U4.IdentityServices.PowerShell" -MinimumVersion "1.0.0.0"

Try {
    $idsClientID = (Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $idsUsername).SecretValueText
    $idsClientSecret = (Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $idsPassword).SecretValueText
}
Catch {
    Throw "Getting IDS Credentials from keyvault failed: $_"
}

Try {
    Disconnect-U4IDS
    Connect-U4IDS -ClientCredentialAuth -IdsUri $idsUri -ClientId $idsClientID -ClientSecret $idsClientSecret
}
Catch {
    Throw "Connecting to $idsUri failed : $_"
}

Try {
    $ClientSettings = Get-U4IDSClient | where ClientId -like $ClientID

    $ClientSettings.PostLogoutRedirectUris.Add("https://$CustomServiceName-portal.$CustomDomain")
    $ClientSettings.PostLogoutRedirectUris.Add("https://$CustomServiceName-portal.$CustomDomain/authorize/token")
    $ClientSettings.PostLogoutRedirectUris.Add("https://$CustomServiceName-portal.$CustomDomain/account/loggedoff")

    $ClientSettings.RedirectUris.Add("https://$CustomServiceName-portal.$CustomDomain")
    $ClientSettings.RedirectUris.Add("https://$CustomServiceName-portal.$CustomDomain/authorize/token")

    Set-U4IDSClient $ClientSettings
}
Catch {
    Throw "Setting Client Settings failed: $_"
}
