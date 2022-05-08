locals {
  kubeconfig = abspath(pathexpand(var.kubeconfig_filename))
  suffix     = random_string.suffix.result
  secret     = random_string.secret.result

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
}
