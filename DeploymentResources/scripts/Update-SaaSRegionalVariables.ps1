param(
    [string]$initial_appInsightsLocation,
    [string]$initial_azureLocation,
    [string]$initial_secondaryRegion,
    [string]$initial_primaryBIGIPURL,
    [string]$initial_secondaryBIGIPURL,
    [string]$initial_primaryStorageAccountName,
    [string]$initial_primaryResourceGroupName
)

Try {
    $StageName = $env:RELEASE_ENVIRONMENTNAME
    Write-verbose "The stage name is $StageName"
}
Catch {
    Write-Error "Can't get the stage name. $_"
}

if ($($StageName.split(' ')[0]) -ne 'SaaS') {
    Write-Host "Seems like this is not a SaaS deployment. Skipped."
}
else {

    $SaaSRegion = $StageName.split(' ')[1]

    #Validate Region
    if (('ASG', 'AUS', 'CAE', 'EUN', 'UKS', 'USS', 'NOE') -contains $SaaSRegion) {
        
        $SaaSRegionLower = $SaaSRegion.ToLower()

        $index = switch ($SaaSRegion) {
            ASG { '0' }
            AUS { '1' }
            CAE { '2' }
            EUN { '3' }
            UKS { '4' }
            USS { '5' }
            NOE { '6' }
        }

        $SaaSRegionSecondary = switch ($SaaSRegion) {
            ASG { 'ase' }
            AUS { 'aue' }
            CAE { 'cac' }
            EUN { 'euw' }
            UKS { 'ukw' }
            USS { 'usn' }
            NOE { 'now' }
        }

        $instance = switch ($StageName.split(' ')[2]) {
            Preview { '-preview' }
            default { '' }
        }

        $instanceShort = switch ($StageName.split(' ')[2]) {
            Preview { 'PREV' }
            default { 'PROD' }
        }

        #Getting Variables
        $Variables = @()
        
        $Variables += New-Object pscustomobject -Property @{
            Name  = 'SaaSRegion'
            Value = $SaaSRegion
        }

        $Variables += New-Object pscustomobject -Property @{
            Name  = 'SaaSRegionSecondary'
            Value = $SaaSRegionSecondary
        }

        $Variables += New-Object pscustomobject -Property @{
            Name  = "SaaSRegionLower"
            Value = $SaaSRegionLower
        }

        $Variables += New-Object pscustomobject -Property @{
            Name  = 'SaaSRegionUpper'
            Value = $SaaSRegionUpper
        }
        
        $Variables += New-Object pscustomobject -Property @{
            Name  = 'SaaSRegionShort'
            Value = $SaaSRegionLower.substring(0, 2)
        }
        
        $Variables += New-Object pscustomobject -Property @{
            Name  = 'instance'
            Value = $instance
        }

        $Variables += New-Object pscustomobject -Property @{
            Name  = 'instanceShort'
            Value = $instanceShort
        }

        $appInsightsLocations = $initial_appInsightsLocation.Split(',')
        $Variables += New-Object pscustomobject -Property @{
            Name  = 'appInsightsLocation'
            Value = $appInsightsLocations[$index]
        }

        $azureLocations = $initial_azureLocation.Split(',')
        $Variables += New-Object pscustomobject -Property @{
            Name  = 'azureLocation'
            Value = $azureLocations[$index]
        }

        $secondaryRegions = $initial_secondaryRegion.Split(',')
        $Variables += New-Object pscustomobject -Property @{
            Name  = 'secondaryRegion'
            Value = $secondaryRegions[$index]
        }

        $primaryBIGIPURLs = $initial_primaryBIGIPURL.Split(',')
        $Variables += New-Object pscustomobject -Property @{
            Name  = 'primaryBIGIPURL'
            Value = $primaryBIGIPURLs[$index]
        }

        $secondaryBIGIPURLs = $initial_secondaryBIGIPURL.Split(',')
        $Variables += New-Object pscustomobject -Property @{
            Name  = 'secondaryBIGIPURL'
            Value = $secondaryBIGIPURLs[$index]
        }

        $primaryStorageAccountNames = $initial_primaryStorageAccountName.Split(',')
        $Variables += New-Object pscustomobject -Property @{
            Name  = 'primaryStorageAccountName'
            Value = $primaryStorageAccountNames[$index]
        }

        $primaryResourceGroupNames = $initial_primaryResourceGroupName.Split(',')
        $Variables += New-Object pscustomobject -Property @{
            Name  = 'primaryResourceGroupName'
            Value = $primaryResourceGroupNames[$index]
        }

        foreach ($Variable in $Variables) {
            Write-host "Publishing SaaS variable: $($Variable.Name)"
            Write-host "##vso[task.setvariable variable=$($Variable.Name)]$($Variable.Value)"
        }
    }
    elseif ($SaaSRegion -eq 'LAB') {
        Write-Host "Seems like this is SaaS LAB deployment. No need for this task. Skipped."
    }
    else {
        Write-Error "$SaaSRegion doesn't match. Allowed values for Region: 'ASG','AUS','CAE','EUN','UKS','USS','NOE'."
    }
}