output "node_resource_group" {
  value       = module.cluster.node_resource_group
  description = "The name of the Resource Group where the Kubernetes Nodes should exist."
}

output "location" {
  value       = module.cluster.location
  description = "The location where the Managed Kubernetes Cluster is created."
}

output "aks_id" {
  value       = module.cluster.aks_id
  description = "The Kubernetes Managed Cluster ID."
}

output "kube_config_raw" {
  value       = module.cluster.kube_config_raw
  description = "Raw Kubernetes config to be used by kubectl and other compatible tools."
}

output "kube_admin_config_raw" {
  value       = module.cluster.kube_admin_config_raw
  description = "Raw Kubernetes config for the admin account to be used by kubectl and other compatible tools. This is only available when Role Based Access Control with Azure Active Directory is enabled and local accounts enabled."
}

output "http_application_routing_zone_name" {
  value       = module.cluster.http_application_routing_zone_name
  description = "The Zone Name of the HTTP Application Routing."
}

output "identity" {
  value       = module.cluster.identity
  description = "The Principal and Tenant IDs associated with this Managed Service Identity."
}

output "kubelet_identity" {
  value       = module.cluster.kubelet_identity
  description = "The Client, Object and User Assigned Identity IDs of the Managed Identity to be assigned to the Kubelets."
}

output "kube_admin_config" {
  value       = module.cluster.kube_admin_config
  description = "Map of credentials to authenticate to Kubernetes as an administrator."
}

output "kube_config" {
  value       = module.cluster.kube_config
  description = "Map of credentials to authenticate to Kubernetes as a user."
}

output "private_key" {
  value       = module.cluster.private_key
  description = "Private key data in PEM (RFC 1421) and OpenSSH PEM (RFC 4716) format."
}

output "public_key" {
  value       = module.cluster.public_key
  description = "Public key data in PEM (RFC 1421) and [Authorized Keys](https://www.ssh.com/academy/ssh/authorized_keys/openssh#format-of-the-authorized-keys-file) format."
}

output "log_analytics_workspace_id" {
  value       = module.cluster.log_analytics_workspace_id
  description = "The Log Analytics Workspace ID."
}
