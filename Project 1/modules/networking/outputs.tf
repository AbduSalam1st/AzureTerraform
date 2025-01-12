output "vnet_id" {
  description = "ID of the created Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "subnet1_id" {
  description = "ID of Subnet1"
  value       = azurerm_subnet.subnet1.id
}

output "subnet_sandbox_id" {
  description = "ID of the sandbox subnet"
  value       = azurerm_subnet.subnet_sandbox.id
}
