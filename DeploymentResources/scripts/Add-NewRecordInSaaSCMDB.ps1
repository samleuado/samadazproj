param(
    #The name of WebApp
    [Parameter(Mandatory = $true)][string]$Name,
    #The resource group of the WebApp 
    [Parameter(Mandatory = $true)][string]$ResourceGroup,
    #Service Name  of the WebApp
    [Parameter(Mandatory = $true)][string]$System,
    #The LogicApp name
    [Parameter(Mandatory = $true)][string]$LogicAppName,
    #The Keyvault name where the LogipApp secrets are stored
    [Parameter(Mandatory = $true)][string]$LogicAppKeyVaultName,
    #Region of the WebApp
    [string]$Region,
    #Service release version
    [string]$ReleaseVersion,
    [string]$ShortDescription,
    [string]$Description
)
# This script adds Record in SaaS CMDB with CI Class Name 'U4-WebApps'

if ($Name.Substring(0,1) -ne 't') {

    $SecurityKey = (Get-AzureKeyVaultSecret -VaultName $LogicAppKeyVaultName -Name "$LogicAppName-key" -ErrorAction Stop).SecretValueText

    $LogicAppUri = (Get-AzureKeyVaultSecret -VaultName $LogicAppKeyVaultName -Name "$LogicAppName-uri" -ErrorAction Stop).SecretValueText

    if(!($SecurityKey -and $LogicAppUri)) {
        Throw "Either LogicApp Security key or LogicApp Uri is null."
    }

    $EnvType = switch ($ResourceGroup.Split('-')[-1]) {
        preview { 'Preview/Acceptance' }
        Default { 'Production' }
    } 
    if (!$Region) {
        $Region = $ResourceGroup.Split('-')[1]
    }
    $CMDB_JsonBody = @{
        Description      = $Description               
        Key              = $SecurityKey
        EnvType          = $EnvType #'Preview/Acceptance', 'Production'
        Name             = $Name  # s-eu-ek1-preview
        Location         = "Azure $($Region.ToUpper())" #Azure ASG, Azure AUS, Azure CAE, Azure EUN, Azure UKS, Azure USS
        System           = $System  # Extension Kit
        ResourceGroup    = $ResourceGroup # s-eun-ek1-preview
        ReleaseVersion   = $ReleaseVersion # 1.0.0
        ShortDescription = $ShortDescription # s-uk-am1-preview.unit4cloud.com, s-uks-am1-preview.azurewebsites.net
    } | ConvertTo-Json

    $CMDB_UpdateRequest = Invoke-WebRequest -Uri $LogicAppUri -Body ($CMDB_JsonBody) -ContentType 'application/json' -Method Post -ErrorAction:Stop

    Write-Output "$($CMDB_UpdateRequest.StatusCode) $($CMDB_UpdateRequest.StatusDescription)"

    if ($CMDB_UpdateRequest.StatusCode -eq '200') {
        Write-Host "$Name has been added to CMDB"
    }
    else {
        Write-Host "Adding CMDB Record needs your attention. Please check the StatusCode: $_"
    }
}
else {
    Write-Host "Seems like this is LAB deployment. No CMDB Record is needed for LAB. Skipped."
}