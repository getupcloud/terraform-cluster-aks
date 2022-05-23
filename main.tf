module "internet" {
  source = "github.com/getupcloud/terraform-module-internet?ref=v1.0"
}

module "flux" {
  source = "github.com/getupcloud/terraform-module-flux?ref=v1.5"

  git_repo       = var.flux_git_repo
  manifests_path = "./clusters/${var.cluster_name}/aks/manifests"
  wait           = var.flux_wait
  flux_version   = var.flux_version

  flux_template_vars = {}

  manifests_template_vars = merge({
    alertmanager_cronitor_id : module.cronitor.cronitor_id
    },
    module.teleport-agent.teleport_agent_config,
    var.manifests_template_vars
  )
}

module "cronitor" {
  source = "github.com/getupcloud/terraform-module-cronitor?ref=v1.0"

  cluster_name  = var.cluster_name
  customer_name = var.customer_name
  cluster_sla   = var.cluster_sla
  suffix        = "aks"
  tags          = [module.cluster.location]
  api_key       = var.cronitor_api_key
  pagerduty_key = var.cronitor_pagerduty_key
  api_endpoint  = module.cluster.host
}

module "teleport-agent" {
  source = "github.com/getupcloud/terraform-module-teleport-agent-config?ref=v0.2"

  auth_token       = var.teleport_auth_token
  cluster_name     = var.cluster_name
  customer_name    = var.customer_name
  cluster_sla      = var.cluster_sla
  cluster_provider = "aks"
  cluster_region   = module.cluster.location
}

data "azurerm_subscription" "primary" {}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azuread_group" "aks_cluster_admins" {
  for_each     = var.rbac_aad_admin_group_names
  display_name = each.key
}

module "cluster" {
  source = "github.com/caruccio/terraform-azurerm-aks?ref=master"
  #source  = "Azure/aks/azurerm"
  #version = "4.14.0"

  resource_group_name  = var.resource_group_name
  client_id            = var.client_id
  client_secret        = var.client_secret
  kubernetes_version   = var.kubernetes_version
  orchestrator_version = var.orchestrator_version != null ? var.orchestrator_version : var.kubernetes_version
  prefix               = var.prefix
  cluster_name         = var.cluster_name
  sku_tier             = var.sku_tier
  tags                 = var.tags

  allowed_maintenance_windows     = var.allowed_maintenance_windows
  not_allowed_maintenance_windows = var.not_allowed_maintenance_windows

  key_vault_secrets_provider_enabled = var.key_vault_secrets_provider_enabled
  key_vault_secrets_provider         = var.key_vault_secrets_provider

  private_cluster_enabled         = var.private_cluster_enabled
  private_dns_zone_id             = var.private_dns_zone_enabled ? data.azurerm_private_dns_zone.aks[0].id : var.private_dns_zone_name
  enable_http_application_routing = var.enable_http_application_routing
  enable_azure_policy             = var.enable_azure_policy
  identity_type                   = var.identity_type
  user_assigned_identity_id       = var.user_assigned_identity_id

  ## default nodepool
  agents_pool_name          = var.default_node_pool.name
  enable_auto_scaling       = var.default_node_pool.enable_auto_scaling
  agents_count              = var.default_node_pool.agents_count
  agents_min_count          = var.default_node_pool.min_count
  agents_max_count          = var.default_node_pool.max_count
  agents_max_pods           = var.default_node_pool.agents_max_pods
  agents_type               = var.default_node_pool.agents_type
  agents_size               = var.default_node_pool.agents_size
  agents_availability_zones = var.default_node_pool.agents_availability_zones
  agents_labels             = var.default_node_pool.agents_labels
  agents_tags               = var.default_node_pool.agents_tags
  os_disk_size_gb           = var.default_node_pool.os_disk_size_gb
  enable_node_public_ip     = var.default_node_pool.enable_node_public_ip
  enable_host_encryption    = var.default_node_pool.enable_host_encryption
  vnet_subnet_id            = var.default_node_pool.vnet_subnet_id

  network_plugin                 = var.network_policy == "azure" ? "azure" : var.network_plugin
  network_policy                 = var.network_policy
  net_profile_dns_service_ip     = var.net_profile_dns_service_ip
  net_profile_docker_bridge_cidr = var.net_profile_docker_bridge_cidr
  net_profile_outbound_type      = var.net_profile_outbound_type
  net_profile_service_cidr       = var.net_profile_service_cidr
  net_profile_pod_cidr           = var.network_plugin == "azure" ? null : var.net_profile_pod_cidr

  enable_role_based_access_control = var.enable_role_based_access_control
  rbac_aad_managed                 = var.rbac_aad_managed
  # managed
  rbac_aad_admin_group_object_ids = local.rbac_aad_admin_group_object_ids
  # unmanaged
  rbac_aad_client_app_id     = var.rbac_aad_client_app_id
  rbac_aad_server_app_id     = var.rbac_aad_server_app_id
  rbac_aad_server_app_secret = var.rbac_aad_server_app_secret

  enable_ingress_application_gateway      = var.enable_ingress_application_gateway
  ingress_application_gateway_name        = var.ingress_application_gateway_name
  ingress_application_gateway_id          = var.ingress_application_gateway_id
  ingress_application_gateway_subnet_cidr = var.ingress_application_gateway_subnet_cidr
  ingress_application_gateway_subnet_id   = var.ingress_application_gateway_subnet_id

  enable_log_analytics_workspace       = var.enable_log_analytics_workspace
  cluster_log_analytics_workspace_name = var.cluster_log_analytics_workspace_name
  log_analytics_workspace_sku          = var.log_analytics_workspace_sku
  log_retention_in_days                = var.log_retention_in_days

}
