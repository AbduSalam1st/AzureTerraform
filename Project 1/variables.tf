variable "subscription_id" {
  type        = string
  description = "Subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Tenant ID"
}

variable "client_id" {
  type        = string
  description = "Client ID for the Azure service principal"
}

variable "client_secret" {
  type        = string
  description = "Client secret for the Azure service principal"
  sensitive   = true
}

variable "resource_group_name" {
  type        = string
  description = "VPC1"
  sensitive = true
}

variable "resource_location" {
  type        = string
  description = "UK South"
  sensitive = true
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM."
}

variable "admin_password" {
  type        = string
  description = "Admin password for the VM."
  sensitive   = true
}
