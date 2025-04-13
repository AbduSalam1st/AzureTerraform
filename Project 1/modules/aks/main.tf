resource "azurerm_kubernetes_cluster" "k8_abdul" {
  name                = "learnk8scluster"
  location            = var.resource_location
  resource_group_name = var.resource_group_name
  dns_prefix          = "learnk8scluster"

  default_node_pool {
    name                 = "default"
    vm_size              = "Standard_B2s"
    node_count           = 1
    min_count            = 1
    max_count            = 2
    auto_scaling_enabled = true
  }

  auto_scaler_profile {
    balance_similar_node_groups = true
    expander                    = "least-waste"
  }

  # If you want to integrate with App Gateway Ingress Controller:
  ingress_application_gateway {
    gateway_id = module.AGIC.appgw_id
  }

  network_profile {
    network_plugin = "azure" # Azure CNI
  }

  identity {
    type = "SystemAssigned"
  }
}

module "AGIC" {
  source = "../AGIC"
  resource_location = var.resource_location
  resource_group_name = var.resource_group_name
}
