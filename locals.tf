locals {
  api_endpoint               = module.cluster.kube_admin_config.host
  client_certificate         = base64decode(module.cluster.kube_admin_config.client_certificate)
  client_key                 = base64decode(module.cluster.kube_admin_config.client_key)
  certificate_authority_data = base64decode(module.cluster.kube_admin_config.cluster_ca_certificate)

  suffix = random_string.suffix.result
  secret = random_string.secret.result

  rbac_aad_admin_group_object_ids = compact(concat([for adm in data.azuread_group.aks_cluster_admins : adm.id], var.rbac_aad_admin_group_object_ids))

  node_pools = {
    for name, np in var.node_pools : name => merge(
      {
        agents_labels = {
          "role" : name
        }
      },
      var.default_node_pool,
      np
    )
  }

  azure_modules        = merge(var.azure_modules_defaults, var.azure_modules)
  azure_modules_output = {}
}
