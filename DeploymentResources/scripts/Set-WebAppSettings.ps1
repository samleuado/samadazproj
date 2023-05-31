param(
    [string]$ResourceGroupName,
    [string]$WebAppName,
    [string]$CustomServiceName,
    [string]$CustomDomain,
    [string]$ServiceNameSuffix,
    [string]$FunctionResponse
)

Try {
    $WebApp = Get-AzureRmWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName
    $WebAppSettings = $WebApp.SiteConfig.AppSettings

    $ExtensionKitUriValue = "https://$CustomServiceName-api.$CustomDomain"
    $FlowHistoryUriValue = "https://$CustomServiceName-flowhistory.$CustomDomain"
    $InvitationsEndpointUriValue = "https://$CustomServiceName-api.$CustomDomain/api/v1/am-invitations"
    $InvitationSenderFunctionUriValue = "https://$CustomServiceName-invitation-sender.$CustomDomain/api/InvitationSender"
    $HibernationUrlValue = "https://$CustomServiceName-hibernation.$CustomDomain"
    $HibernationWakeupCallbackUrlValue = "https://$CustomServiceName-$ServiceNameSuffix.$CustomDomain/api/$FunctionResponse"
    $StoreConfigurationPortalUriValue = "https://$CustomServiceName-portal.$CustomDomain"
    $ExtensionsApiUriValue = "https://$CustomServiceName-extensions.$CustomDomain"
    $FlowsApiUriValue = "https://$CustomServiceName-flows.$CustomDomain"
    $TenantsApiUriValue = "https://$CustomServiceName-tenants.$CustomDomain"
    $XsltFunctionUriValue = "https://$CustomServiceName-functions-xslt.$CustomDomain"


    $index = [array]::IndexOf($WebAppSettings.name, 'ExtensionsKitUri')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $ExtensionKitUriValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'ExtensionKit:PublicApiUrl')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $ExtensionKitUriValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'ExtensionKit:PublicApiUri')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $ExtensionKitUriValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'FlowHistoryUri')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $FlowHistoryUriValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'InvitationsEndpointUri')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $InvitationsEndpointUriValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'InvitationSenderFunctionUri')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $InvitationSenderFunctionUriValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'Hibernation:Url')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $HibernationUrlValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'Hibernation:WakeupCallbackUrl')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $HibernationWakeupCallbackUrlValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'StoreConfiguration:ApiUriExtensionsKit')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $ExtensionKitUriValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'StoreConfiguration:PortalUri')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $StoreConfigurationPortalUriValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'Hibernation:CallbackUrl')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $HibernationWakeupCallbackUrlValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'ExtensionsApiUri')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $ExtensionsApiUriValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'FlowsApiUri')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $FlowsApiUriValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'ExtensionKit:ExtensionsApiUri')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $ExtensionsApiUriValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'ExtensionsKitPublicApiUri')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $ExtensionKitUriValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'TenantsApiUri')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $TenantsApiUriValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'ExtensionKit:TenantsApiUrl')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $TenantsApiUriValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'TenantsApi:TenantsApiUri')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $TenantsApiUriValue
    }
    $index = [array]::IndexOf($WebAppSettings.name, 'Xslt:Url')
    if ($index -ge 0) {
        $WebAppSettings[$index].Value = $XsltFunctionUriValue
    }
    
    $WebApp.SiteConfig.AppSettings = $WebAppSettings

    Set-AzureRmWebApp $WebApp

    Write-Verbose "WebApp config settings have been successfully set."
}
Catch {
    Throw "Setting WebApp Config for $WebAppName failed: $_"
}

Try {
    Write-Verbose "Restarting WebApp $WebAppName"
    Restart-AzureRmWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName
}
Catch {
    throw "Restarting $WebAppName failed: $_"
}