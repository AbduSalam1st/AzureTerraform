output "VPCinfo_output" {
  value = azurerm_virtual_network.VPC1
  description = "Details of the created Virtual Network"
}

output "subnetInfo_output" {
  value = [
    for subnet in azurerm_subnet.subnets :
    {
      name                 = subnet.name
      resource_group_name  = subnet.resource_group_name
      virtual_network_name = subnet.virtual_network_name
      address_prefixes     = subnet.address_prefixes
    }
  ]
  description = "Details of the created Subnets"
}