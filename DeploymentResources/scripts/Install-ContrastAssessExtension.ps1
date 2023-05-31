param([string[]]$siteList, [hashtable]$appSettings, [string]$subscriptionID, [string]$resourceGroupNameEntry, [string]$enviromentType="QA", [string]$runtime="core")

function Install-ContrastExtension {
    param ($resourceGroup,$webapp,$contrastExtension)

    $installationStatus = New-AzResource -Name "$webapp/$contrastExtension" -ResourceGroupName $resourceGroup -ResourceType "Microsoft.Web/sites/siteextensions" -ApiVersion "2018-02-01" -force
    if ($installationStatus.Properties.provisioningState -eq "Succeeded") {
        Write-Output "Contrast Assess extension installed in $webapp"
        return $true
    }
    else {
        Write-Output "ERROR: Installation of Contrast Assess failed"
        return $false
    }
}

$resourceGroupName = $resourceGroupNameEntry
if($runtime -eq "core") {
    $contrastExtension = "Contrast.NetCore.Azure.SiteExtension"
} elseif($runtime -eq "framework") {
    $contrastExtension = "Contrast.NET.Azure.SiteExtension"
} else {
    Write-Output "Unknonwn runtime"
    exit -1
}

foreach($webService in $siteList) {
    
    try {
        $installedExtension = Get-AzResource -Name "$webService/$contrastExtension" -ResourceGroupName $resourceGroupName -ResourceType "Microsoft.Web/sites/siteextensions" -ApiVersion "2018-02-01" -ErrorAction ignore
    }
    catch {
        Write-Output "No Contrast Assess Extension detected in app $webService"
        Write-Output "`nError Message: " $_.Exception.Message
    }

    #If no extension installed then install
    if ($null -eq $installedExtension) {
        Write-Output "No Contrast extension installed. Starting installation"
        if (!(Install-ContrastExtension -resourceGroup $resourceGroupName -webapp $webService -contrastExtension $contrastExtension)) {
            Write-Output "Error installing Contrast Extension"
            exit -1
        }
    }
    #If extension is already installed
    else {
        #Get installed version of Contrast Extension
        Write-Output "Contrast extension already exists. Checking version of installed Contrast extension in $webService"    
        $accessToken=Get-AzAccessToken
        $AzureDevOpsAuthenicationHeader = @{Authorization = 'Bearer ' + $($accessToken.Token) } 

        $installedExtensionURI ="https://management.azure.com/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.Web/sites/$webService/siteextensions?api-version=2019-08-01"
        $azureLibraryURI ="https://management.azure.com/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/Microsoft.Web/sites/$webService/extensions/api/extensionfeed?api-version=2018-11-01"

        $installedExtensioninfo= Invoke-RestMethod -Uri $installedExtensionURI -Method get -Headers $azureDevOpsAuthenicationHeader
        $publishExtensionInfo= Invoke-RestMethod -Uri $azureLibraryURI -Method get -Headers $azureDevOpsAuthenicationHeader

        [System.Version]$installedVersion = ($installedExtensioninfo.value | where {($_.name -like "*$contrastExtension*")}).properties.version
        [System.Version]$publishedVersion = ($publishExtensionInfo.value | where {($_.name -like "*$contrastExtension*")}).properties.version

        if ($installedVersion -lt $publishedVersion) {
            #Uninstalled old version
            Write-Output "Old version of Contrast Assess detected: $installedVersion. Starting uninstall"
            Remove-AzResource -Name "$webService/$contrastExtension" -ResourceGroupName $resourceGroupName -ResourceType "Microsoft.Web/sites/siteextensions" -ApiVersion "2018-02-01" -force
            #Delay to let the deinstallation finish in order to install the new version
            Start-Sleep -s 40
            Write-Output "Old version of Contrast Assess uninstalled. Starting installation of version $publishedVersion"
            
            if (!(Install-ContrastExtension -resourceGroup $resourceGroupName -webapp $webService -contrastExtension $contrastExtension)) {
                Write-Output "Error installing Contrast Extension $publishedVersion"
                exit -1
            }
        }
        else {
            Write-Output "Contrast extension installed in $($webService) is latest version --> $installedVersion"
        }
    }
    
    #Add application Variables
    try {
        write-Output "Info: Getting settings from web service $webservice from resourceGroup $resourceGroupName"
        $webserviceObject = Get-AzWebapp -Resourcegroup $resourceGroupName -name $webService
    } catch {
        Write-Output "Error: Failed to get application settings in $webService"
        Write-Output "`nError Message: " $_.Exception.Message
    }
    if ($null -ne $webserviceObject) {
        $modSettings = @{}
        foreach ($setting in $webserviceObject.SiteConfig.AppSettings) {
            if (!($appSettings.ContainsKey($setting.Name))) {
                $modSettings[$setting.Name] = $setting.Value
            }
        }
        $modSettings += $appSettings
        $modSettings."CONTRAST__SERVER__NAME" = $webService
        $modSettings."CONTRAST__SERVER__ENVIRONMENT" = $enviromentType

        $httpLogConfig = $false
        if ($webserviceObject.SiteConfig.HttpLoggingEnabled) {
            $httpLogConfig = $true
        }
        try {
            $setWebappOutput = Set-AzWebApp -Resourcegroup $resourceGroupName -name $webService -AppSettings $modSettings -HttpLoggingEnabled $httpLogConfig
        } catch {
            Write-Output "Error: Failed to set application settings in $webService"
            Write-Output "`nError Message: " $_.Exception.Message
        }
        if ($null -ne $setWebappOutput) {
            Restart-AzWebApp  -ResourceGroupName $resourceGroupName -Name $webService
        }
    } 
}
