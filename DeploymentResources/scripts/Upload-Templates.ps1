<#

    This script uploads the different services arm templates to a shared Azure Storage.
    This way the main ARM template 'extensionskit-template.json' can access those templates by link.
    (ARM templates do not allow local references to files, only URLs )

    For example, for the given template entry:
     @{  
        Name               = 'Extensions/actionDaPushTextV1'; 
        ArtifactVersion    = 10.0
        DeploymentTemplate = "$WorkingDirectory/Actions.DaPushText/resources/da-push-text-function-app-template.json"
    }

    Will create a new Blob in the container (DeploymentResourcesContainer)/Extensions/actionDaPushTextV1/10.0/da-push-text-function-app-template.json.

    The DeploymentTemplate can be: 
        - A json file. In this case the file will be uploaded.
        - A directory. In this case all the files in the directory fill be uploaded.
 #>
param(
    [string]$ResourceGroup,
    [string]$DeploymentResourcesStorageAccount,
    [string]$DeploymentResourcesContainer,
    [string]$WorkingDirectory
)

$templateInfo = @(
    @{  
        Name               = 'Extensions/actionDaPushTextV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_DAPUSHTEXT_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.DaPushText/resources/da-push-text-function-app-template.json"
    },
    @{  
        Name               = 'Extensions/actionDaTravelRequestV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_DAPUSHTRAVELREQUEST_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.DaPushTravelRequest/resources/da-push-travel-request-function-app-template.json"
    },
    @{  
        Name               = 'Extensions/actionDaQuestionV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_DAQUESTION_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.DaQuestion/resources/da-question-function-app-template.json"
    },
    @{  
        Name               = 'Extensions/actionEmailV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_EMAIL_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.Email/resources/email-function-app-template.json"
    },
    @{  
        Name               = 'Extensions/actionEventGridV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_EVENTGRIDPUBLISH_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.EventGridPublish/resources/base-extension-function-app-template.json"
    },
    @{  
        Name               = 'Extensions/actionForEachV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_FOREACH_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.ForEach/resources/base-extension-function-app-template.json"
    },
    @{  
        Name               = 'Extensions/actionHttpRequestV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_HTTP_REQUEST_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.Http.Request/resources/http-request-function-app-template.json"
    },
    @{  
        Name               = 'Extensions/actionInstantUIV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_INSTANTUI_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.InstantUI/resources/instant-ui-function-app-template.json"
    }, 
    @{  
        Name               = 'Extensions/actionJsonParseV2'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_GENERAL_JSONPARSE_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.General.JsonParse/resources/base-extension-function-app-template.json"
    }, 
    @{  
        Name               = 'Extensions/actionMHActorV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_MESSAGEHUBACTOR_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.MessageHubActor/resources/mh-actor-function-app-template.json"
    }, 
    @{  
        Name               = 'Extensions/actionMHEventV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_MESSAGEHUBEVENT_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.MessageHubEvent/resources/mh-event-function-app-template.json"
    },
    @{  
        Name               = 'Extensions/actionPgpEncryptV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_PGPENCRYPT_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.PgpEncrypt/resources/base-extension-function-app-template.json"
    },
    @{  
        Name               = 'Extensions/actionPgpDecryptV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_PGPDECRYPT_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.PgpDecrypt/resources/base-extension-function-app-template.json"
    },
    @{  
        Name               = 'Extensions/actionSftpCreateV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_SFTPCREATE_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.SftpCreate/resources/sftp-create-function-app-template.json"
    }, 
    @{  
        Name               = 'Extensions/actionSftpDeleteV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_SFTPDELETE_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.SftpDelete/resources/sftp-delete-function-app-template.json"
    }, 
    @{  
        Name               = 'Extensions/actionSftpGetContentV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_SFTPGETCONTENT_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.SftpGetContent/resources/sftp-get-content-function-app-template.json"
    }, 
    @{  
        Name               = 'Extensions/actionSftpListV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_SFTPLIST_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.SftpList/resources/sftp-list-function-app-template.json"
    }, 
    @{  
        Name               = 'Extensions/actionStopV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_STOP_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.Stop/resources/base-extension-function-app-template.json"
    }, 
    @{  
        Name               = 'Extensions/actionUnit4IdResolverV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_UNIT4IDRESOLVER_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.Unit4IdResolver/resources/unit4id-resolver-function-app-template.json"
    }, 
    @{  
        Name               = 'Extensions/actionXmlParseV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_XMLPARSE_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.XmlParse/resources/base-extension-function-app-template.json"
    }, 
    @{  
        Name               = 'Extensions/actionXsltV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_XSLT_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.Xslt/resources/base-extension-function-app-template.json"
    }, 
    @{  
        Name               = 'Extensions/actionXslt3V1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_XSLT3_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.Xslt3/resources/xslt3-function-app-template.json"
    },
    @{  
        Name               = 'Extensions/actionJsonToXmlV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_JSONTOXML_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.JsonToXml/resources/base-extension-function-app-template.json"
    },
    @{
        Name               = 'Extensions/actionSignXmlV1';
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_SIGNXML_BUILDNUMBER;
        DeploymentTemplate = "$WorkingDirectory/Actions.SignXml/resources/certificate-function-app-template.json"
    }
    @{  
        Name               = 'Extensions/actionVerifyXmlV1';
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_VERIFYXML_BUILDNUMBER;
        DeploymentTemplate = "$WorkingDirectory/Actions.VerifyXml/resources/certificate-function-app-template.json"
    }
    @{  
        Name               = 'Extensions/actionXmlEncryptV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_XMLENCRYPT_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Actions.XmlEncrypt/resources/certificate-function-app-template.json"
    }
    @{  
        Name               = 'API'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_API_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/API/resources/api-template.json"
    }, 
    @{  
        Name               = 'Extensions/API'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_EXTENSIONSAPI_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/ExtensionsAPI/resources/extensions-api-template.json"
    }, 
    @{  
        Name               = 'FlowHistory'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_FLOWHISTORY_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/FlowHistory/resources"
    }, 
    @{  
        Name               = 'FlowMetricsFunction'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_FUNCTIONS_FLOWMETRICS_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Functions.FlowMetrics/resources/function-app-template-dotnet.json"
    }, 
    @{  
        Name               = 'XsltProcessorFunction'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_FUNCTIONS_XSLT_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Functions.Xslt/resources/xslt-function-app-template.json"
    }, 
    @{  
        Name               = 'FlowService'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_FLOWSERVICE_API_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/FlowService.API/resources/flow-service-api.json"
    }, 
    @{  
        Name               = 'HibernationServices'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_HIBERNATION_BUILDNUMBER 
        DeploymentTemplate = "$WorkingDirectory/Hibernation/resources/hibernationservice-template.json"
    }, 
    @{  
        
        Name               = 'InvitationSenderFunction'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_FUNCTIONS_INVITATIONSENDER_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Functions.InvitationSender/resources/function-invitation-sender-template.json"
    }, 
    @{  
        Name               = 'NotificationsFunction'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_NOTIFICATIONSERVICES_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/NotificationServices/resources/function-flow-notification-app-template.json"
    }, 
    @{  
        Name               = 'Orchestrator'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ORCHESTRATOR_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Orchestrator/resources/orchestrator-template.json"
    }, 
    @{  
        Name               = 'Portal'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_PORTAL_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Portal/resources/portal-template.json"
    },
    @{  
        Name               = 'Tenants'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_TENANTDOMAIN_API_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/TenantDomain.API/resources/tenant-service.json"
    },
    @{  
        Name               = 'TenantsConsumption'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_TENANTDOMAIN_CONSUMPTIONUPDATER_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/TenantDomain.ConsumptionUpdater/resources/tenant-consumption-updater.json"
    },
    @{  
        Name               = 'Extensions/triggerMessageHubV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_TRIGGERS_MESSAGEHUB_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Triggers.MessageHub/resources/mhevents-template.json"
    },
    @{  
        Name               = 'Extensions/triggerSchedulerV1'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_TRIGGERS_SCHEDULER_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Triggers.Scheduler/resources/scheduler-template.json"
    },
    @{  
        Name               = 'Extensions/triggerHttpWebhookV2'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_TRIGGERS_HTTPWEBHOOKV2_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/Triggers.HttpWebhookV2/resources/webhook-v2-template.json"
    },
    @{  
        Name               = 'TenantActivationFunction'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_TENANTDOMAIN_TAF_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/TenantDomain.TAF/resources/tenant-activation-function.json"
    }, 
    @{  
        Name               = 'shared'; 
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_DEVOPS_RESOURCES_BUILDNUMBER; 
        DeploymentTemplate = "$WorkingDirectory/DevOps.Resources/DeploymentResources/arm/shared-resources";
    },
    @{  
        Name               = 'Extensions/actionXmlDecryptV1';
        ArtifactVersion    = $env:RELEASE_ARTIFACTS_ACTIONS_XMLDECRYPT_BUILDNUMBER;
        DeploymentTemplate = "$WorkingDirectory/Actions.XmlDecrypt/resources/certificate-function-app-template.json"
    }
)

Set-AzCurrentStorageAccount -ResourceGroupName $ResourceGroup -Name $DeploymentResourcesStorageAccount

Foreach ($template in $templateInfo) {
    $destinationBlobFolder = $template['Name'];
    $artifactVersionPath = $template['ArtifactVersion'];
    $blobName = $template['DeploymentTemplate'].Split("/")[-1];
    $fullBlobPath = "$destinationBlobFolder/$artifactVersionPath/";

    if ($blobName.EndsWith(".json")) {
        $fullBlobPath += $blobName;
        Set-AzStorageBlobContent -File $template.DeploymentTemplate -Container $DeploymentResourcesContainer -Blob $fullBlobPath -Force
    } elseif($blobName.Contains(".")) {
        Write-Error "Template file is: $blobName. Only supported type for ARM templates is .json extension."
    } elseif((Get-Item $template['DeploymentTemplate']) -is [System.IO.DirectoryInfo]) {
        $directory = $template['DeploymentTemplate'];
        $files = Get-ChildItem -Path $directory;
        Foreach ($file in $files) {
            Set-AzStorageBlobContent -File "$directory/$file" -Container $DeploymentResourcesContainer -Blob "$fullBlobPath$file" -Force
        }
    }
}