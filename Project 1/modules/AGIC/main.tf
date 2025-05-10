# resource "azurerm_virtual_network" "agw_vnet" {
#   name                = var.appgw_vnet_name
#   resource_group_name = var.resource_group_name
#   location            = var.resource_location
#   address_space       = ["192.168.0.0/16"]
# }

# resource "azurerm_subnet" "agw_subnet" {
#   name                 = var.appgw_subnet_name
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.agw_vnet.name
#   address_prefixes     = ["192.168.40.0/24"]
# }

# resource "azurerm_public_ip" "appgw_public_ip" {
#   name                = var.appgw_public_ip_name
#   resource_group_name = var.resource_group_name
#   location            = var.resource_location
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# resource "azurerm_user_assigned_identity" "appgw_identity" {
#   name                = var.appgw_identity_name
#   resource_group_name = var.resource_group_name
#   location            = var.resource_location
# }

# resource "azurerm_application_gateway" "this" {
#   name                = var.appgw_name
#   location            = var.resource_location
#   resource_group_name = var.resource_group_name

#   sku {
#     name     = "Standard_v2"
#     tier     = "Standard_v2"
#     capacity = 2
#   }

#   gateway_ip_configuration {
#     name      = "appgwIpConfig"
#     subnet_id = azurerm_subnet.agw_subnet.id
#   }

#   frontend_port {
#     name = "frontendPort"
#     port = 80
#   }

#   frontend_ip_configuration {
#     name                 = "publicIPAddress"
#     public_ip_address_id = azurerm_public_ip.appgw_public_ip.id
#   }

#   http_listener {
#     name                           = "listener"
#     frontend_ip_configuration_name = "publicIPAddress"
#     frontend_port_name             = "frontendPort"
#     protocol                       = "Http"
#   }

#   request_routing_rule {
#     name                       = "rule1"
#     http_listener_name         = "listener"
#     rule_type                  = "Basic"
#     backend_address_pool_name  = "dummyAddressPool"
#     backend_http_settings_name = "dummyHttpSetting"
#     priority                   = 9
#   }

#   # Dummy backend to make the config valid.
#   backend_address_pool {
#     name = "dummyAddressPool"
#   }

#   backend_http_settings {
#     name                  = "dummyHttpSetting"
#     path                  = "/path1/"
#     protocol              = "Http"
#     port                  = 80
#     request_timeout       = 30
#     cookie_based_affinity = "Disabled"
#   }

#   identity {
#     type         = "UserAssigned"
#     identity_ids = [azurerm_user_assigned_identity.appgw_identity.id]
#   }
# }

# resource "azurerm_role_assignment" "appgw_role_assignment" {
#   principal_id         = azurerm_user_assigned_identity.appgw_identity.principal_id
#   role_definition_name = "Network Contributor"
#   scope                = azurerm_virtual_network.agw_vnet.id
# }
