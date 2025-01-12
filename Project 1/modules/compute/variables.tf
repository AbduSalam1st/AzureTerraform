variable "resource_group_name" {
  type = string
}

variable "resource_location" {
  type = string
}

variable "vm_name" {
  type    = string
  default = "Workstation1"
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "subnet_id" {
  type        = string
  description = "The Subnet ID where this VM NIC will be placed."
}
