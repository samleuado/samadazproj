[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$ResourceGroupName,
    [Parameter(Mandatory=$true)][string]$ServiceName,
    [Parameter(Mandatory=$true)][string]$ExtensionKitUri,
    [Parameter(Mandatory=$true)][string]$ExtensionKitWebhookUri,
    [Parameter(Mandatory=$true)][string]$ExtensionKitWebhookV2Uri
)

$Context = Try {
    New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ServiceName
}
Catch {
    Throw "Failed to create context: $_"
}

Try {
    # ExtensionKitUri
    $ExtensionKitUriProperty = Get-AzApiManagementNamedValue -Context $Context -Name ExtensionsKitUri

    if ($ExtensionKitUriProperty.Value -like "$ExtensionKitUri") {
    
        Write-Host "Property ExtensionKitUri has the proper value." -ForegroundColor Green
    } 
    else {
        
        Set-AzApiManagementNamedValue -Context $Context -NamedValueId $ExtensionKitUriProperty.NamedValueId -Value $ExtensionKitUri
        
        Write-Host "Property ExtensionKitUri Value is set to $ExtensionKitUri."
    }
    
    # ExtensionKitWebhookUri
    $ExtensionKitWebhookUriProperty = Get-AzApiManagementNamedValue -Context $Context -Name ExtensionsKitWebhookUri

    if ($ExtensionKitWebhookUriProperty.Value -like "$ExtensionKitWebhookUri") {
    
        Write-Host "Property ExtensionKitWebhookUri has the proper value." -ForegroundColor Green
    } 
    else {
        
        Set-AzApiManagementNamedValue -Context $Context -NamedValueId $ExtensionKitWebhookUriProperty.NamedValueId -Value $ExtensionKitWebhookUri
        
        Write-Host "Property ExtensionKitWebhookUri Value is set to $ExtensionKitWebhookUri."
    }
    
    # ExtensionKitWebhookV2Uri
    $ExtensionKitWebhookUriV2Property = Get-AzApiManagementNamedValue -Context $Context -Name ExtensionsKitWebhookV2Uri

    if ($ExtensionKitWebhookUriV2Property.Value -like "$ExtensionKitWebhookV2Uri") {
    
        Write-Host "Property ExtensionKitWebhookV2Uri has the proper value." -ForegroundColor Green
    } 
    else {
        
        Set-AzApiManagementNamedValue -Context $Context -NamedValueId $ExtensionKitWebhookUriV2Property.NamedValueId -Value $ExtensionKitWebhookV2Uri
        
        Write-Host "Property ExtensionKitWebhookV2Uri Value is set to $ExtensionKitWebhookV2Uri."
    }
}
Catch {
    
    Throw "Setting API Management Property failed: $_"
}
