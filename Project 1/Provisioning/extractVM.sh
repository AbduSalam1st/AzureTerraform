#!/bin/bash

TFVARS_FILE="./terraform.tfvars"
# Define variables for subscription, resource group, and workspace
SUBSCRIPTION_ID="a365b477-080f-4a9f-a22f-0b42a1f9b091"
RESOURCE_GROUP="resource-group-1"
WORKSPACE_NAME="sentinel-log-analytics"

# Define the KQL query to extract VM name
QUERY="SecurityAlert | where AlertName contains 'Virtual Machine' | extend VMName = tostring(parse_json(Entities)[0].Name) | project VMName | take 1"

# Run the Azure CLI command to execute the KQL query
VM_NAME=$(az monitor log-analytics query \
  --workspace "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/$WORKSPACE_NAME" \
  --analytics-query "$QUERY" \
  --out tsv)

# Check if the VM_NAME is empty
if [ -z "$VM_NAME" ]; then
  echo "Error: Could not fetch the VM name. Check your Sentinel alerts and KQL query."
  exit 1
fi

# Output the VM name in JSON format for Terraform
echo "{\"vm_name\": \"$VM_NAME\"}"
