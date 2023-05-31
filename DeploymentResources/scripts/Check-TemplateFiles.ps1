[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$ResourceGroupName,
    [Parameter(Mandatory=$true)][string]$StorageAccountName,
    [Parameter(Mandatory=$true)][string]$ContainerName,
    [Parameter(ParameterSetName='PublishSASTokenOnly',Mandatory=$false)][string]$ArtifactSourceAlias,
    [Parameter(ParameterSetName='PublishSASTokenOnly')][switch]$PublishContainerCredentialsOnly
)
function Check-StorageBlob {
    [CmdletBinding()]
    param (
        [string]$ContainerName,
        [string]$BlobName,
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.IStorageContext]$Context
    )

    Write-Host "Checking Blob $BlobName"

    $Blobs = Try {
        Get-AzStorageBlob -Container $ContainerName -Context $Context -ErrorAction SilentlyContinue | where { $_.Name -like  "$BlobName*" } #"shared/$BuildNumber*" }
    }
    Catch {
        Throw "$_"
    }

    #check if the files exist
    if(($Blobs.Count -gt 0) -and ($Blobs[0].Length -gt 0) -and ($Blobs[0].IsDeleted -eq $false)) {
        Write-Host "Templates in $BlobName already exist."
        Return $true
    }
    else {
        Write-Host "Templates in $BlobName do not exist or not up to date."
        Return $false
    }
}
function Result-Positive {
    param(
        [string]$BlobPrefix
    )
        $VariableName = $BlobPrefix + 'TemplatesExist'

        #publish variable to skip Copy Files task
        Write-host "##vso[task.setvariable variable=$VariableName]Yes"
}
function Result-Negative {
    param(
        [string]$BlobPrefix
    )
   
    $VariableName = $BlobPrefix + 'TemplatesExist'
    
    #publish variable to skip Copy Files task
    Write-host "##vso[task.setvariable variable=$VariableName]No"
}

function Publish-ContainerCredentials {
    param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$SASToken,
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$ContainerURI
    )

    Write-Host "Publishing ArtifactsContainerUri and ArtifactsContainerSasToken."

    #publish ArtifactsContainerSasToken
    Write-host "##vso[task.setvariable variable=ArtifactsContainerSasToken;issecret=true]$SASToken"
    
    #publish ArtifactsContainerUri
    Write-host "##vso[task.setvariable variable=ArtifactsContainerUri]$ContainerURI"
}

function New-ContainerCredentials {
    param(
        [Parameter(Mandatory=$true)][string]$ContainerName,
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.IStorageContext]$Context
    )

    #get Container Uri
    $ContainerURI = Try {
        (Get-AzStorageContainer -Name $ContainerName -Context $Context).CloudBlobContainer.Uri.AbsoluteUri
    }
    Catch {
        Throw "Getting Container URI failed: $_" 
    }
    # Fix for URI
    if (!$ContainerURI.EndsWith('/')) {
        $ContainerURI = $ContainerURI +'/'
    }
    #create SASToken
    $SASToken = Try {
        New-AzStorageContainerSASToken -Name $ContainerName -Permission R -Context $Context
    }
    Catch {
        Throw "SAS Token creation failed: $_"
    }

    $Result = New-Object psobject -Property @{
        SASToken = $SASToken
        ContainerURI = $ContainerURI
    }

    Return $Result
}

#get Access key for storage account
$AccessKey = Try {
    (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Value[0]
}
Catch {
    Throw "Getting StorageAccountKey for Storage Account $StorageAccountName failed: $_"
}
#create a context
$Context = Try {
    New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $AccessKey
}
Catch {
    Throw "Creating Context for Storage Account $StorageAccountName failed: $_"
}
# Process
if ($PublishContainerCredentialsOnly.IsPresent) {
    
    $Credentials = New-ContainerCredentials -Context $Context -ContainerName $ContainerName

    $Credentials | Publish-ContainerCredentials
}
else {

    $ArtifactSourceAliases = $ArtifactSourceAlias.Split(',')

    foreach ($Alias in $ArtifactSourceAliases) {

        #get the build number
        $ArtifactSource = $Alias.ToUpper()
        $BuildNumberVariable = "RELEASE_ARTIFACTS_"+$ArtifactSource + "_RESOURCES_BUILDNUMBER"
        $BuildNumber = (Get-ChildItem Env: | where { $_.name -like "$BuildNumberVariable"}).Value

        #get Blob prefix
        if($BlobPrefix -eq 'DevOps') {
            $BlobPrefix = 'shared'
        }
        else {
            $BlobPrefix = $Alias
        }
    
        $Exists = Check-StorageBlob -ContainerName $ContainerName -BlobName "$BlobPrefix/$BuildNumber" -Context $Context

        if($Exists) { 
            if (!$Credentials) {
                Try {
                    $Credentials = New-ContainerCredentials -Context $Context -ContainerName $ContainerName

                    $Credentials | Publish-ContainerCredentials
                }
                Catch {
                    Throw "Publishing Container Credentials failed: $_"
                }
            }
            Result-Positive -BlobPrefix $BlobPrefix
        }
        else {
            Result-Negative -BlobPrefix $BlobPrefix
        }
    }
}