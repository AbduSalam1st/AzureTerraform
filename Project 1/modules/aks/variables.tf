variable "resource_group_name" {
  type = string
}

variable "resource_location" {
  type = string
}

# If using the ingress_application_gateway block
# pass the App Gateway ID from the app_gateway module
variable "application_gateway_id" {
  type        = string
  description = "ID of the existing Application Gateway (optional if not using AGIC)."
  default     = ""
}
