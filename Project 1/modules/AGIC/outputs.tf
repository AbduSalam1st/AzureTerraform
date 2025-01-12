output "appgw_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.this.id
}

output "appgw_identity_id" {
  description = "User Assigned Identity ID for Application Gateway"
  value       = azurerm_user_assigned_identity.appgw_identity.id
}
