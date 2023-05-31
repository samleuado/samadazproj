<#
Script which remove all archive tier blob whose last modification was previous 
than a certain date
#>

param(
  [Parameter(Mandatory=$true, HelpMessage="Resource Group name")]
  [string]
  $ResourceGroupName,
  
  [Parameter(Mandatory=$true, HelpMessage="Storage Account name")]
  [string]
  $StorageAccountName,
  
  [Parameter(Mandatory=$true, HelpMessage="Blob container name")]
  [string]
  $ContainerName
)

# Custom variables
$StorageAccount = Get-AzStorageAccount `
  -ResourceGroupName $ResourceGroupName `
  -Name $StorageAccountName
$Context = $StorageAccount.Context
$CutOffDate = Get-Date

# Delete archive blobs
Get-AzStorageBlob `
  -Container $ContainerName `
  -Context $Context `
| Where-Object { `
  $_.AccessTier -eq "Archive" -and `
  $_.LastModified -lt $CutOffDate `
} `
| Remove-AzStorageBlob
