terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14.0"
    }
  }
}

provider "azurerm" {
  client_id       = var.client_id
  client_secret   = var.clientSecret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {

  }
}

# Configure the Microsoft Azure Provider

# Create a resource group
resource "azurerm_resource_group" "region" {
  name     = var.resource_group_name
  location = var.resoruce_location
}



# This is the networking module regarding the Virtual Networks, Subnets etc.check "name" 

resource "azurerm_virtual_network" "VPC" {
  name                = "VPC1"
  address_space       = ["10.0.0.0/16"]
  location            = var.resoruce_location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  name                 = "Subnet1"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.VPC.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "sandboxEnviroment"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.VPC.name
  address_prefixes     = ["10.0.100.0/24"]
}



resource "azurerm_virtual_network" "AGW" {
  name                = "AGW_Network"
  resource_group_name = azurerm_resource_group.region.name
  location            = azurerm_resource_group.region.location
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "AGWSub" {
  name                 = "AGW_Subnet"
  resource_group_name  = azurerm_resource_group.region.name
  virtual_network_name = azurerm_virtual_network.AGW.name
  address_prefixes     = ["192.168.1.0/24"]
}

# output "VPCinfo_details" {
#   value       =  module.networking.VPCinfo_output
#   description = "Details of the created Virtual Network"
# }

# output "subnetInfo_details" {
#   value       = module.networking.subnetInfo_output
#   description = "Details of the created Subnets"
# }

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "learnk8scluster"
  location            = var.resoruce_location
  resource_group_name = var.resource_group_name
  dns_prefix          = "learnk8scluster"

  default_node_pool {
    name                 = "default"
    vm_size              = "Standard_B2s"
    node_count           = 1
    min_count            = 1
    max_count            = 3
    auto_scaling_enabled = true
  }

  auto_scaler_profile {
    balance_similar_node_groups = true
    expander                    = "least-waste"
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.appgw.id
  }

  network_profile {
    network_plugin = "azure" # Use Azure CNI (non-overlay)
  }
  identity {
    type = "SystemAssigned"
  }
  # http_application_routing_enabled = true /////CHECK THIS BIT OF CODE OUT AS AZURE HAS DEPRECATED USING ADDONS.
}


resource "azurerm_public_ip" "appgw_public_ip" {
  name                = "appgw-public-ip"
  resource_group_name = azurerm_resource_group.region.name
  location            = azurerm_resource_group.region.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

///APPLICATION GATEWAY RESOURCE
resource "azurerm_application_gateway" "appgw" {
  name                = "appgw-waf"
  location            = var.resoruce_location
  resource_group_name = var.resource_group_name
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgwIpConfig"
    subnet_id = azurerm_subnet.AGWSub.id
  }

  frontend_port {
    name = "frontendPort"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "publicIPAddress"
    public_ip_address_id = azurerm_public_ip.appgw_public_ip.id
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "publicIPAddress"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule1"
    http_listener_name         = "listener"
    rule_type                  = "Basic"
    backend_address_pool_name  = "dummyAddressPool"
    backend_http_settings_name = "dummyHttpSetting"
    priority                   = 9
  }

  # Dummy backend to make the config valid.
  backend_address_pool {
    name = "dummyAddressPool"
  }

  backend_http_settings {
    name                  = "dummyHttpSetting"
    path                  = "/path1/"
    protocol              = "Http"
    port                  = 80
    request_timeout       = 30
    cookie_based_affinity = "Disabled"
  }

  # waf_configuration {
  #   enabled          = true
  #   firewall_mode    = "Prevention"
  #   rule_set_type    = "OWASP"
  #   rule_set_version = "3.2"
  # }

  # Add Managed Identity if needed for AGIC
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agic_identity.id]
  }
}

resource "azurerm_user_assigned_identity" "agic_identity" {
  name                = "agic-identity"
  resource_group_name = azurerm_resource_group.region.name
  location            = azurerm_resource_group.region.location
}

resource "azurerm_role_assignment" "agic_network_contributor" {
  principal_id         = azurerm_user_assigned_identity.agic_identity.principal_id
  role_definition_name = "Network Contributor"
  scope                = azurerm_resource_group.region.id
}



# module "security" {
#   source = "./security"
# }


# resource "azurerm_log_analytics_workspace" "sentinel_workspace" {
#   name                = "sentinel-log-analytics"
#   resource_group_name = var.resource_group_name
#   location            = var.resoruce_location
#   sku                 = "PerGB2018"
#   retention_in_days   = 30
# }

# resource "azurerm_sentinel_log_analytics_workspace_onboarding" "onboardingSentinel" {
#   workspace_id = azurerm_log_analytics_workspace.sentinel_workspace.id
# }


# resource "azurerm_sentinel_alert_rule_scheduled" "scheduledRule" {
#   name                       = "scheduledRule"
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.sentinel_workspace.id
#   display_name               = azurerm_log_analytics_workspace.sentinel_workspace.id
#   severity                   = "High"
#   query                      = <<QUERY
# AzureActivity |
#   where OperationName == "Create or Update Virtual Machine" or OperationName =="Create Deployment" |
#   where ActivityStatus == "Succeeded" |
#   make-series dcount(ResourceId) default=0 on EventSubmissionTimestamp in range(ago(7d), now(), 1d) by Caller
# QUERY
# }

# resource "azurerm_storage_account" "abdulstorage1" {
#   name                     = "abdulstorage1"
#   resource_group_name      = var.resource_group_name
#   location                 = var.resoruce_location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"
# }

# resource "azurerm_service_plan" "servicePlan" {
#   name                = "example-app-service-plan"
#   resource_group_name = var.resource_group_name
#   location            = var.resoruce_location
#   os_type             = "Linux"
#   sku_name            = "B1"
# }

# resource "azurerm_linux_function_app" "sandbox_function" {
#   name                       = "abdulsandboxing"
#   resource_group_name        = var.resource_group_name
#   location                   = var.resoruce_location
#   service_plan_id            = azurerm_service_plan.servicePlan.id
#   storage_account_name       = azurerm_storage_account.abdulstorage1.name
#   storage_account_access_key = azurerm_storage_account.abdulstorage1.primary_access_key

#   site_config {
#   }

#    app_settings = {
#     FUNCTIONS_WORKER_RUNTIME = "python"
#     AzureWebJobsStorage      = azurerm_storage_account.abdulstorage1.primary_connection_string
#   }

#   identity {
#     type = "SystemAssigned"
#   }
# }


# resource "azurerm_logic_app_workflow" "FunctionTrigger" {
#   name                = "SentinelTriggerAlert"
#   location            = var.resoruce_location
#   resource_group_name = var.resource_group_name
#   enabled = true

#   workflow_schema  = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
#   workflow_version = "1.0.0.0"

  
# }


# resource "azurerm_resource_group_template_deployment" "resourceGroupTemplate" {
#   name                = "deploy"
#   resource_group_name = var.resource_group_name
#   deployment_mode     = "Incremental"
#   parameters_content = jsonencode({
#     "vnetName" = {
#       value = "VPC1"
#     }
#   })
#   template_content = <<TEMPLATE
# {
#     "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
#     "contentVersion": "1.0.0.0",
#     "parameters": {
#         "vnetName": {
#             "type": "string",
#             "metadata": {
#                 "description": "Name of the VNET"
#             }
#         }
#     },
#     "variables": {},
#     "resources": [
#         {
#             "type": "Microsoft.Network/virtualNetworks",
#             "apiVersion": "2020-05-01",
#             "name": "[parameters('vnetName')]",
#             "location": "[resourceGroup().location]",
#             "properties": {
#                 "addressSpace": {
#                     "addressPrefixes": [
#                         "10.0.0.0/16"
#                     ]
#                 }
#             }
#         }
#     ],
#     "outputs": {
#       "exampleOutput": {
#         "type": "string",
#         "value": "someoutput"
#       }
#     }
# }
# TEMPLATE

#   // NOTE: whilst we show an inline template here, we recommend
#   // sourcing this from a file for readability/editor support
# }

# output "arm_example_output" {
#   value = jsondecode(azurerm_resource_group_template_deployment.resourceGroupTemplate.output_content).exampleOutput.value
# }


# resource "azurerm_network_security_group" "sandbox_nsg" {
#   name                = "sandbox-nsg"
#   location            = var.resoruce_location
#   resource_group_name = var.resource_group_name

#   security_rule {
#     name                       = "Deny-All"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Deny"
#     protocol                   = "*"
#     source_port_range          = "*"
#     destination_port_range     = "*"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }

# Logic App Workflow
resource "azurerm_logic_app_workflow" "sandbox_logic_app" {
  name                = "Trigger_Sandbox_Isolation"
  location            = var.resoruce_location
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }
}

# API Connection: Azure Sentinel
resource "azurerm_logic_app_api_connection" "sentinel_connection" {
  name                = "azuresentinel-Trigger_Sandbox_Isolation"
  location            = var.resoruce_location
  resource_group_name = var.resource_group_name

  properties {
    api = {
      id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Web/locations/${var.resoruce_location}/managedApis/azuresentinel"
    }

    authentication = {
      type = "ManagedServiceIdentity"
    }
  }
}

# API Connection: ARM (for VM operations)
resource "azurerm_logic_app_api_connection" "arm_connection" {
  name                = "arm-1"
  location            = var.resoruce_location
  resource_group_name = var.resource_group_name

  properties {
    api = {
      id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Web/locations/${var.resoruce_location}/managedApis/arm"
    }

    authentication = {
      type = "ManagedServiceIdentity"
    }
  }
}

# Role Assignment for Managed Identity to Deallocate VMs
resource "azurerm_role_assignment" "logic_app_vm_role" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_logic_app_workflow.sandbox_logic_app.identity[0].principal_id
}

# Role Assignment for Sentinel API Connection
resource "azurerm_role_assignment" "logic_app_sentinel_role" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Microsoft Sentinel Responder"
  principal_id         = azurerm_logic_app_workflow.sandbox_logic_app.identity[0].principal_id
}

# Output Logic App Workflow Identity
output "logic_app_identity" {
  value = azurerm_logic_app_workflow.sandbox_logic_app.identity[0].principal_id
}

# Variables for Subscription
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}