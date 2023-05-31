[CmdletBinding()]
param(
    # URI of Identity Services endpoint, used to work with Identity Services and to obtain bearer tokens for calls to other micro-services.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$IdsUrl,

    # URI of the Access Management endpoint, used to work with Access Management and to obtain bearer tokens for calls to other micro-services.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$AmsUrl,

    # URI of Extension Kit endpoint, where to send an Invitation acces email.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$EkUrl,

    # Name of Access Management scope
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$AmsApiScope,

    [Parameter()]
    [AllowEmptyString()]
    [string]$NugetRepository = 'nuget-dev',

    # Name of Key Vault of the EK instance where all secrets are stored.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$KeyVaultName,

    # Name of Client Id to connect to AM.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$AccessManagementClientId,

    # Name of Secret Id to connect to AM.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$AccessManagementClientSecretId,

    # The Extension Kit service base name
    [Parameter()]
    [ValidateNotNullorEmpty()]
    [string]$ServiceName,

    # Extension Kit Source System name to provision.
    [Parameter()]
    [ValidateNotNullorEmpty()]
    [string]$SourceSystem,

    # Verified Existing Tenant Id the Invitee belongs to
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$TenantId,

    # Verified Existing Tenant Id the Inviter belongs to
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$InvitedByTenant,

    # Email address of user to send invitation email access to EK portal
    [parameter()]
    [AllowEmptyString()]
    [string]$Email,

    [parameter()]
    [AllowEmptyString()]
    [string]$Email2,

    [parameter()]
    [AllowEmptyString()]
    [string]$Email3,

    # Role assigned to a user within tenant Id in EK portal
    [parameter()]
    [AllowEmptyString()]
    [string]$Roles,
    
    [parameter()]
    [AllowEmptyString()]
    [string]$Roles2,

    [parameter()]
    [AllowEmptyString()]
    [string]$Roles3,

    # Name of user
    [parameter()]
    [AllowEmptyString()]
    [string]$Name,

    [parameter()]
    [AllowEmptyString()]
    [string]$Name2,

    [parameter()]
    [AllowEmptyString()]
    [string]$Name3,

    # User who is part of the Admin Tenant
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$InvitedBy,

    # Tenant name of the customer to be displayed in the portal
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$TenantName,

    # Short name of the customers' Tenant ID
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$ShortName,

    # Custom Logo URL of the customer
    [Parameter()]
    [string]$LogoUrl,

    # The path where the Invitation file is stored
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$InvitationFile,

    # The path where the file is storing
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$WorkingDirectory,

    # Source Location of package
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$SourceLocation,

    # Sender Name of email
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$SenderName,

    # Sender Name of email
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$SenderAddress,

    # Subject of the Invitation Email
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Subject
)

# Register Repository
Write-Host "Checking for a PSRepository with source $SourceLocation"

$Repository = Get-PSRepository -Name "U4PPDev" -ErrorAction SilentlyContinue
if (-not $Repository) {
    Write-Host "Registering PSRepository $Repository with source $SourceLocation"

    Register-PSRepository -Name "U4PPDev" -Source $SourceLocation -PublishLocation $SourceLocation -InstallationPolicy Trusted -ErrorAction Stop
    Write-Host "PSRepository $Repository has been registered with source location $SourceLocation" -ForegroundColor:Green
    
    $Repository = Get-PSRepository -Name "U4PPDev"
    Write-Host "Repository: $Repository" -ForegroundColor Green
}

if ($null -eq (Get-AzContext).Account) {
    throw "No Azure RM Context available. Script will stop"
}


# Install Access Management PS module
#Install-Module -Name "U4.AccessManagement.Powershell" -Repository $Repository -Scope AllUsers -MinimumVersion '3.0.21267.3' -Force
Import-Module "$WorkingDirectory\DevOps.Resources\DeploymentResources\scripts\Nuget-Utilities.psm1" -Force
Install-NuGetPackage -NugetFeedName "U4PPDev" -NugetFeedUri "https://packages.u4pp.com/$NugetRepository/nuget/" -ModuleName "U4.AccessManagement.PowerShell" -MinimumVersion "3.0.21267.3"

# Connect to Access Management instance
Connect-U4AM -IdsUri $IdsUrl -AmUri $AmsUrl -ClientId $AccessManagementClientId -ClientSecret $AccessManagementClientSecretId -AmScope $AmsApiScope

# Check if EK Source System exists in this instance
if ($null -eq (Get-U4AMSourceSystem -SourceSystemId $SourceSystem)) {
    Write-Host "Adding SourceSystem $SourceSystem" -ForegroundColor Green
    $SourceSystem = New-U4AMSourceSystem -SourceSystemId $SourceSystem -Description "Extension Kit Source System ($SourceSystem)" -Roles "Owner,Contributor,Reader"
    Add-U4AMSourceSystem $SourceSystem | Out-Null
} 
else {
    Write-Host "SourceSystem $SourceSystem already exists and ready to go" -ForegroundColor Green
}

# Check if EK Tenant ID exists in this instance
if ($null -eq (Get-U4AMTenant -SourceSystemId $SourceSystem -TenantId $TenantId)) {
    Write-Host "No such $TenantId found in SourceSystem $SourceSystem" -ErrorAction Stop -ForegroundColor Yellow
}
else {
    Write-Host "Tenant $TenantId already exists in SourceSystem $SourceSystem and ready to go" -ForegroundColor Green
}

#USER1
# Convert an array objects to JSON format
$UserList = ConvertTo-Json @(
    [PSCustomObject]@{
        Name  = "$Name"
        Email = "$Email"
        Roles = @("$Roles")
    }
)

# Create Invitation file with token
Try {
    if (![string]::IsNullOrEmpty($Email)) {
        Add-U4AMInvitations -SourceSystemId $SourceSystem -TenantId $TenantId -InvitedBy $InvitedBy -InvitedByTenant $InvitedByTenant -UsersJson $Userlist -SaveResultLocalFilePath "$WorkingDirectory\InvitationUserList.txt" -Verbose
        Write-Host "Invitation file is created" -ForegroundColor Green
    }
    else {
        Write-Host "Email value is empty, skipping it"
    }
}
Catch {
    Throw "Adding Invitation tokens to a file has failed: $_"
}

# Send Invitation email from the file
Try {
    if (![string]::IsNullOrEmpty($Email)) {
        Send-U4AMInvitationEmail -Subject $Subject -SenderName $SenderName -SenderAddress $SenderAddress -BaseUri $EkUrl -TenantId $TenantId -TenantName $TenantName -TenantAlias $ShortName -FromFiles -HtmlTemplateLocalFilePath $InvitationFile -InvitationsJsonLocalFilePath "$WorkingDirectory\InvitationUserList.txt"
        Write-Host "The email has been sent successfully." -ForegroundColor Green
    }
    else {
        Write-Host "Email value is empty, skipping it"
    }
}
Catch {
    Throw "Sending an email has failed: $_"
}

#USER2
# Convert an array objects to JSON format
$UserList2 = ConvertTo-Json @(
    [PSCustomObject]@{
        Name  = "$Name2"
        Email = "$Email2"
        Roles = @("$Roles2")
    }
)

# Create Invitation file with token
Try {
    if (![string]::IsNullOrEmpty($Email2)) {
        Add-U4AMInvitations -SourceSystemId $SourceSystem -TenantId $TenantId -InvitedBy $InvitedBy -InvitedByTenant $InvitedByTenant -UsersJson $Userlist2 -SaveResultLocalFilePath "$WorkingDirectory\InvitationUserList.txt" -Verbose
        Write-Host "Invitation file is created" -ForegroundColor Green
    }
    else {
        Write-Host "Email2 value is empty, skipping it"
    }
}
Catch {
    Throw "Adding Invitation tokens to a file has failed: $_"
}

# Send Invitation email from the file
Try {
    if (![string]::IsNullOrEmpty($Email2)) {
        Send-U4AMInvitationEmail -Subject $Subject -SenderName $SenderName -SenderAddress $SenderAddress -BaseUri $EkUrl -TenantId $TenantId -TenantName $TenantName -TenantAlias $ShortName -FromFiles -HtmlTemplateLocalFilePath $InvitationFile -InvitationsJsonLocalFilePath "$WorkingDirectory\InvitationUserList.txt"
        Write-Host "The email has been sent successfully." -ForegroundColor Green
    }
    else {
        Write-Host "Email2 value is empty, skipping it"
    }
}
Catch {
    Throw "Sending an email has failed: $_"
}

#USER3
# Convert an array objects to JSON format
$UserList3 = ConvertTo-Json @(
    [PSCustomObject]@{
        Name  = "$Name3"
        Email = "$Email3"
        Roles = @("$Roles3")
    }
)

# Create Invitation file with token
Try {
    if (![string]::IsNullOrEmpty($Email3)) {
        Add-U4AMInvitations -SourceSystemId $SourceSystem -TenantId $TenantId -InvitedBy $InvitedBy -InvitedByTenant $InvitedByTenant -UsersJson $Userlist3 -SaveResultLocalFilePath "$WorkingDirectory\InvitationUserList.txt" -Verbose
        Write-Host "Invitation file is created" -ForegroundColor Green
    }
    else {
        Write-Host "Email3 value is empty, skipping it"
    }
}
Catch {
    Throw "Adding Invitation tokens to a file has failed: $_"
}

# Send Invitation email from the file
Try {
    if (![string]::IsNullOrEmpty($Email3)) {
        Send-U4AMInvitationEmail -Subject $Subject -SenderName $SenderName -SenderAddress $SenderAddress -BaseUri $EkUrl -TenantId $TenantId -TenantName $TenantName -TenantAlias $ShortName -FromFiles -HtmlTemplateLocalFilePath $InvitationFile -InvitationsJsonLocalFilePath "$WorkingDirectory\InvitationUserList.txt"
        Write-Host "The email has been sent successfully." -ForegroundColor Green
    }
    else {
        Write-Host "Email3 value is empty, skipping it"
    }
}
Catch {
    Throw "Sending an email has failed: $_"
}