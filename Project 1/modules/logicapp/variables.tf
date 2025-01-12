variable "resource_group_name" {
  type = string
}

variable "resource_location" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "vm_name" {
  type        = string
  description = "VM name for role assignment scope"
  default     = "Workstation1"
}
