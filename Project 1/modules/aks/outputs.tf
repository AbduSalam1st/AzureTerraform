output "aks_id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.k8_abdul.id
}

output "kube_config" {
  description = "Kube config of the AKS cluster"
  value       = azurerm_kubernetes_cluster.k8_abdul.kube_config_raw
  sensitive   = true
}
