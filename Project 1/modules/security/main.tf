# Resource Group might already exist in 'networking' or root; 
# Only create if you truly need a separate RG
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.resource_location
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "sentinel_workspace" {
  name                = "sentinel-log-analytics"
  location            = var.resource_location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Microsoft Sentinel Onboarding
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel_onboarding" {
  workspace_id = azurerm_log_analytics_workspace.sentinel_workspace.id
}

# Analytics Rule for VM Creation or Modification
resource "azurerm_sentinel_alert_rule_scheduled" "vm_creation_alert" {
  name                       = "Alert_VM_Creation"
  display_name               = "Detect VM Creation"
  severity                   = "High"
  enabled                    = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.sentinel_workspace.id

  query = <<QUERY
AzureActivity
| where OperationName == "Microsoft.Compute/virtualMachines/write"
| where ActivityStatus == "Succeeded"
QUERY

  query_frequency   = "PT5M"
  query_period      = "PT60M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  incident {
    create_incident_enabled = true
    grouping {
      enabled = true
    }
  }
}

# Automation Rule to Trigger Logic App
resource "azurerm_sentinel_automation_rule" "trigger_logic_app" {
  name                       = "56094f72-ac3f-40e7-a0c0-47bd95f70336"
  display_name               = "automation_rule1"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
  order                      = 1

  action_incident {
    order  = 1
    status = "Active"
  }
}
