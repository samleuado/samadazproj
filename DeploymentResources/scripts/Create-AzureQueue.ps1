param(
    [string]$ExtensionKitServiceName,
    [string]$QueueName
)

$storageAccountName = $ExtensionKitServiceName.replace('-', '')

$storageAccount = Get-AzStorageAccount -ResourceGroupName $ExtensionKitServiceName -Name $storageAccountName
$ctx = $storageAccount.Context

$azureStorageQueue = Get-AzStorageQueue -Context $ctx | Where-Object {$_.Name -eq $QueueName}
if ($azureStorageQueue -eq $null)
{
    New-AzStorageQueue -Name $QueueName -Context $ctx
}        