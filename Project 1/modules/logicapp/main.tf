resource "azurerm_logic_app_workflow" "this" {
  name                = "Trigger_Sandbox_Isolation"
  location            = var.resource_location
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }
}

# Role assignment at the resource group level so the Logic App can manage resources
resource "azurerm_role_assignment" "logic_app_rg_role" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_logic_app_workflow.this.identity[0].principal_id
}

# If you need a role assignment for deallocating a specific VM
resource "azurerm_role_assignment" "vm_deallocation_role" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Compute/virtualMachines/${var.vm_name}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_logic_app_workflow.this.identity[0].principal_id
}

# Resource group reference
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.resource_location
  # If the RG is already created in the root or in networking,
  # you can data-source or just omit this resource if you prefer.
}
