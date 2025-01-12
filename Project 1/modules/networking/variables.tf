variable "resource_group_name" {
  type = string
}

variable "resource_location" {
  type = string
}

variable "vnet_name" {
  type    = string
  default = "VPC1"
}

variable "subnet1_name" {
  type    = string
  default = "Subnet1"
}

variable "subnet_sandbox_name" {
  type    = string
  default = "sandboxEnviroment"
}
