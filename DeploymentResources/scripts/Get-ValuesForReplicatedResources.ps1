param(
    [string]$primaryResourceGroupName,
    [string]$primaryStorageAccountName
)

### Event Grid Topic ###

$primaryEventGridTopicEndpoint = Get-AzEventGridTopic -ResourceGroupName $primaryResourceGroupName -Name $primaryResourceGroupName
$primaryEventGridTopicEndpoint = $primaryEventGridTopicEndpoint.Endpoint
Write-Host "Event Grid Topic Endpoint URI" $primaryEventGridTopicEndpoint

$primaryEventGridTopicAccessKey = Get-AzEventGridTopicKey -ResourceGroupName $primaryResourceGroupName -Name $primaryResourceGroupName
$primaryEventGridTopicAccessKey = $primaryEventGridTopicAccessKey.Key1
Write-Host "Event Grid Topic Key" $primaryEventGridTopicAccessKey

### Storage Account ###

$primaryStorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $primaryResourceGroupName -Name $primaryStorageAccountName)[0].Value
Write-Host "Storage Account Key" $primaryStorageAccountKey

$primaryStorageAccountConnectionString = "DefaultEndpointsProtocol=https;AccountName=$primaryStorageAccountName;AccountKey=$primaryStorageAccountKey;EndpointSuffix=core.windows.net"
Write-Host "Storage Account Connection String" $primaryStorageAccountConnectionString

### Cosmos DB ###

$primaryDocumentDbUri = "https://$primaryResourceGroupName.documents.azure.com:443/"
Write-Host "Cosmos DB URI" $primaryDocumentDbUri

$primaryDocumentDbConnectionString = Get-AzCosmosDBAccountKey -ResourceGroupName $primaryResourceGroupName -Name $primaryResourceGroupName -Type "ConnectionStrings"
$primaryDocumentDbConnectionString = $primaryDocumentDbConnectionString["Primary SQL Connection String"]
Write-Host "Cosmos DB Primary Connection String" $primaryDocumentDbConnectionString

$primaryDocumentDbKey = Get-AzCosmosDBAccountKey -ResourceGroupName $primaryResourceGroupName -Name $primaryResourceGroupName -Type "keys"
$primaryDocumentDbKey = $primaryDocumentDbKey["PrimaryMasterKey"]
Write-Host "Cosmos DB Primary Key" $primaryDocumentDbKey

### Redis ###

$primaryRedisUri = "https://$primaryResourceGroupName.redis.cache.windows.net"
Write-Host "Redis Primary Uri" $primaryRedisUri

$primaryRedisKey = Get-AzRedisCacheKey -ResourceGroupName $primaryResourceGroupName -Name $primaryResourceGroupName
$primaryRedisKey = $primaryRedisKey["PrimaryKey"]
Write-Host "Redis Primary Key" $primaryRedisKey

### Pass variables to the Task for resources deployment ###

Write-Host "##vso[task.setvariable variable=primaryEventGridTopicEndpoint]$primaryEventGridTopicEndpoint"
Write-Host "##vso[task.setvariable variable=primaryEventGridTopicAccessKey;issecret=true]$primaryEventGridTopicAccessKey"
Write-Host "##vso[task.setvariable variable=primaryStorageAccountConnectionString;issecret=true]$primaryStorageAccountConnectionString"
Write-Host "##vso[task.setvariable variable=primaryDocumentDbUri]$primaryDocumentDbUri"
Write-Host "##vso[task.setvariable variable=primaryDocumentDbKey;issecret=true]$primaryDocumentDbKey"
Write-Host "##vso[task.setvariable variable=primaryDocumentDbConnectionString;issecret=true]$primaryDocumentDbConnectionString"
Write-Host "##vso[task.setvariable variable=primaryRedisUri]$primaryRedisUri"
Write-Host "##vso[task.setvariable variable=primaryRedisKey;issecret=true]$primaryRedisKey"