# resource "azurerm_virtual_network" "VPC1" {
#   name                = var.VPCinfo.name
#   resource_group_name = var.VPCinfo.resource_group_name
#   location            = var.VPCinfo.location
#   address_space       = var.VPCinfo.address_space
# }

# resource "azurerm_subnet" "subnets" {
#   for_each = { for subnet in var.subnetInfo : subnet.name => subnet }

#   name                 = each.value.name
#   resource_group_name  = var.VPCinfo.resource_group_name
#   virtual_network_name = azurerm_virtual_network.VPC1.name
#   address_prefixes     = each.value.address_prefixes

#   depends_on = [azurerm_virtual_network.VPC1]
# }




# # module "networking" {
# #   source = "./networking"
# #   VPCinfo = {
# #     name                = "VPC1"
# #     resource_group_name = var.resource_group_name
# #     location            = var.resoruce_location
# #     address_space       = ["10.0.0.0/16"]
# #   }

# #   subnetInfo = [
# #     {
# #       name             = "Subnet1"
# #       address_prefixes = ["10.0.1.0/24"]
# #     },
# #      {
# #       name             = "Subnet2"
# #       address_prefixes = ["10.0.3.0/24"]
# #     }
# #   ]
# # }