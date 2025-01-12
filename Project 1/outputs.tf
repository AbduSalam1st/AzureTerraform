output "vm_id" {
  description = "ID of the created VM"
  value       = module.vm.vm_id
}

output "aks_kube_config" {
  description = "Kube config of the AKS cluster"
  value       = module.aks.kube_config
  sensitive   = true
}
