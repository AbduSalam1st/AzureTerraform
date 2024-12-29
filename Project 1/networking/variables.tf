variable "VPCinfo" {
  type = object({
    name                = string
    resource_group_name = string
    location            = string
    address_space       = list(string)
  })
}

variable "subnetInfo" {
  type = list(object({
    name                 = string
    address_prefixes     = list(string)
  }))
}

# variable "default_resource_group_name" {
#   type    = string
#   default = null
# }

# variable "default_virtual_network_name" {
#   type    = string
#   default = null
# }