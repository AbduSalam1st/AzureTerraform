output "vm_id" {
  description = "The ID of the virtual machine"
  value       = azurerm_virtual_machine.this.id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = azurerm_virtual_machine.this.name
}
