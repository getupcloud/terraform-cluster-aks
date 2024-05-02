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

  modules_result = {
    for name, config in merge(var.modules, local.modules) : name => merge(config, {
      output : config.enabled ? lookup(local.register_modules, name, try(config.output, tomap({}))) : tomap({})
    })
  }

  manifests_template_vars = merge(
    {
      alertmanager_cronitor_id : var.cronitor_id
      alertmanager_opsgenie_integration_api_key : var.opsgenie_integration_api_key
      secret : random_string.secret.result
      suffix : random_string.suffix.result
      modules : local.modules_result
    },
    module.teleport-agent.teleport_agent_config,
    var.manifests_template_vars
  )
}
