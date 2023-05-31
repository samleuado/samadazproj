#!/bin/bash
echo "This script will delete the deployments in resource group $1 older than $2 days"

START_DATE=$(date +%F -d "-$2days")
DEPLOYMENTS=($(az deployment group list --resource-group $1 --query "[?properties.timestamp<'$START_DATE'].name" --output tsv))

NUMBER_OF_DEPLOYMENTS=${#DEPLOYMENTS[@]}
echo "Total deployments to delete $NUMBER_OF_DEPLOYMENTS"

echo "Starting to delete deployments..."

for DEPLOYMENT in "${DEPLOYMENTS[@]}"
do
  az deployment group delete --resource-group $1 --name $DEPLOYMENT
done