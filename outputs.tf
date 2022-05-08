output "client_key" {
  value = module.cluster.client_key
}

output "client_certificate" {
  value = module.cluster.client_certificate
}

output "cluster_ca_certificate" {
  value = module.cluster.cluster_ca_certificate
}

output "host" {
  value = module.cluster.host
}

output "username" {
  value = module.cluster.username
}

output "password" {
  value = module.cluster.password
}

output "node_resource_group" {
  value = module.cluster.node_resource_group
}

output "location" {
  value = module.cluster.location
}

output "aks_id" {
  value = module.cluster.aks_id
}

output "kube_config_raw" {
  sensitive = true
  value     = module.cluster.kube_config_raw
}

output "kube_admin_config_raw" {
  sensitive = true
  value     = module.cluster.kube_admin_config_raw
}

output "http_application_routing_zone_name" {
  value = module.cluster.http_application_routing_zone_name
}

output "system_assigned_identity" {
  value = module.cluster.system_assigned_identity
}

output "kubelet_identity" {
  value = module.cluster.kubelet_identity
}

output "admin_client_key" {
  value = module.cluster.admin_client_key
}

output "admin_client_certificate" {
  value = module.cluster.admin_client_certificate
}

output "admin_cluster_ca_certificate" {
  value = module.cluster.admin_cluster_ca_certificate
}

output "admin_host" {
  value = module.cluster.admin_host
}

output "admin_username" {
  value = module.cluster.admin_username
}

output "admin_password" {
  value = module.cluster.admin_password
}
