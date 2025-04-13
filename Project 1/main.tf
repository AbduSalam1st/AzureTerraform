# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.25.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

# ---------------------
# MODULE: Networking
# ---------------------
module "networking" {
  source = "./modules/networking"

  resource_group_name = var.resource_group_name
  resource_location   = var.resource_location

  # Example of passing custom naming if needed
  vnet_name           = "VPC1"
  subnet1_name        = "Subnet1"
  subnet_sandbox_name = "sandboxEnviroment"
}

# ---------------------
# MODULE: Virtual Machine
# ---------------------
module "vm" {
  source = "./modules/compute"

  resource_group_name = var.resource_group_name
  resource_location   = var.resource_location

  # Pass the Subnet ID from Networking module output
  subnet_id = module.networking.subnet1_id

  admin_username = var.admin_username
  admin_password = var.admin_password
  vm_name        = "Workstation1"
}

# ---------------------
# MODULE: AKS Cluster
# ---------------------
module "aks" {
  source = "./modules/aks"

  resource_group_name = var.resource_group_name
  resource_location   = var.resource_location

  # If you need the Application Gateway ID from another module,
  # you can fetch it once we define that module below.
  # But for now, we will reference module.appgw.appgw_id
  # (once the app_gateway module is built).
}

# ---------------------
# MODULE: Application Gateway
# ---------------------
module "appgw" {
  source = "./modules/AGIC"

  resource_group_name = var.resource_group_name
  resource_location   = var.resource_location

  # Provide any custom naming
  appgw_vnet_name      = "AGW_Network"
  appgw_subnet_name    = "AGW_Subnet"
  appgw_public_ip_name = "appgw-public-ip"
  appgw_name           = "appgw-waf"
}

# # ---------------------
# # MODULE: Sentinel & Log Analytics
# # ---------------------
# module "sentinel" {
#   source = "./modules/security"

#   resource_group_name = var.resource_group_name
#   resource_location   = var.resource_location
# }
