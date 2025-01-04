variable "clientSecret" {
  type      = string
  sensitive = true
}

variable "client_id" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type      = string
  sensitive = true
}

variable "subscription_id" {
  type      = string
  sensitive = true
}

variable "resource_group_name" {
  type    = string
  default = "resource-group-1"
}

variable "resoruce_location" {
  type    = string
  default = "UK South"
}

variable "logic_app_name" {
  default = "Trigger_Sandbox_Isolation"
}

variable "computer_name" {
  type = string
  sensitive = true
}

variable "admin_username" {
  type = string
  sensitive = true
}

variable "admin_password" {
   type = string
   sensitive = true
}

