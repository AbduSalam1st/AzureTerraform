#!/bin/bash

# Load variables from terraform.tfvars
TFVARS_FILE="./terraform.tfvars"

if [[ -f "$TFVARS_FILE" ]]; then
  set -a
  source "$TFVARS_FILE"
  set +a
else
  echo "Error: $TFVARS_FILE not found."
  exit 1
fi

# Verify required variables
if [[ -z "$subscription_id" || -z "$resource_group" || -z "$workspace_name" ]]; then
  echo "Error: Required variables are not set. Check your terraform.tfvars file."
  if [[ -z "$subscription_id" ]]; then echo "Missing: subscription_id"; fi
  if [[ -z "$resource_group" ]]; then echo "Missing: resource_group"; fi
  if [[ -z "$workspace_name" ]]; then echo "Missing: workspace_name"; fi
  exit 1
fi

# Check Azure CLI login status
if ! az account show &> /dev/null; then
  echo "Error: Azure CLI is not logged in. Run 'az login' to authenticate."
  exit 1
fi

# Validate the Log Analytics workspace
az monitor log-analytics workspace show \
  --resource-group "$resource_group" \
  --workspace-name "$workspace_name" &> /dev/null
if [[ $? -ne 0 ]]; then
  echo "Error: Log Analytics workspace does not exist or is inaccessible."
  exit 1
fi

# Define the KQL query to extract VM name
QUERY="SecurityAlert | where AlertName contains 'Virtual Machine' | extend VMName = tostring(parse_json(Entities)[0].Name) | project VMName | take 1"

# Run the Azure CLI command to execute the KQL query
VM_NAME=$(az monitor log-analytics query \
  --workspace "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.OperationalInsights/workspaces/$workspace_name" \
  --analytics-query "$QUERY" \
  --out tsv)

# Check if the VM_NAME is empty
if [ -z "$VM_NAME" ]; then
  echo "Error: Could not fetch the VM name. Check your Sentinel alerts and KQL query."
  echo "Debug Info: Workspace - $workspace_name, Resource Group - $resource_group, Subscription - $subscription_id"
  exit 1
fi

# Output the VM name in JSON format for Terraform
echo "{\"vm_name\": \"$VM_NAME\"}"
