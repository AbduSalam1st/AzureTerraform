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

resource "azurerm_subnet" "Subnet1" {
  name                 = "Subnet1"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.VPC.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "sandboxEnviroment" {
  name                 = "sandboxEnviroment"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.VPC.name
  address_prefixes     = ["10.0.100.0/24"]
}


variable "vm_name" {
  description = "Name of the virtual machine to manage based on Sentinel alert"
  type        = string
}

resource "azurerm_network_interface" "VM_network_interface" {
  name                = "NIC"
  location            = var.resoruce_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.Subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "Workstation1" {
  name                  = "Workstation1"
  location              = var.resoruce_location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.VM_network_interface.id]
  vm_size               = "Standard_DS1_v2"


  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.computer_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "testing"
  }
}

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

resource "azurerm_virtual_network" "AGW" {
  name                = "AGW_Network"
  resource_group_name = var.resource_group_name
  location            = var.resoruce_location
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "AGWSub" {
  name                 = "AGW_Subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.AGW.name
  address_prefixes     = ["192.168.40.0/24"]
}



resource "azurerm_public_ip" "appgw_public_ip" {
  name                = "appgw-public-ip"
  resource_group_name = var.resource_group_name
  location            = var.resoruce_location
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
  resource_group_name = var.resource_group_name
  location            = var.resoruce_location
}

resource "azurerm_role_assignment" "agic_network_contributor" {
  principal_id         = azurerm_user_assigned_identity.agic_identity.principal_id
  role_definition_name = "Network Contributor"
  scope                = azurerm_resource_group.region.id
}


# module "security" {
# Terraform Configuration for Azure Sentinel Automation Sandboxing Infrastructure



resource "azurerm_resource_group" "sandbox" {
  name     = var.resource_group_name
  location = var.resoruce_location
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "sentinel_workspace" {
  name                = "sentinel-log-analytics"
  location            = var.resoruce_location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Microsoft Sentinel Instance

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

  query_frequency = "PT5M"
  query_period    = "PT60M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  incident {
    create_incident_enabled = true
    grouping{
      enabled = true
    }
  }
}
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinelAnalytics" {
  workspace_id = azurerm_log_analytics_workspace.sentinel_workspace.id
}

# Automation Rule to Trigger Logic App
resource "azurerm_sentinel_automation_rule" "triggerlogicapp" {
  name                       = "56094f72-ac3f-40e7-a0c0-47bd95f70336"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinelAnalytics.workspace_id
  display_name               = "automation_rule1"
  order                      = 1
  action_incident {
    order  = 1
    status = "Active"
  }
}

resource "azurerm_logic_app_workflow" "sandbox_logic_app" {
  name                = "Trigger_Sandbox_Isolation"
  location            = var.resoruce_location
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "logic_app_role" {
  scope                = azurerm_resource_group.region.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_logic_app_workflow.sandbox_logic_app.identity[0].principal_id
}

resource "azurerm_role_assignment" "vm_deallocation_role" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Compute/virtualMachines//${azurerm_virtual_machine.Workstation1.name}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_logic_app_workflow.sandbox_logic_app.identity[0].principal_id
}
