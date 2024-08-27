module "internet" {
  source = "github.com/getupcloud/terraform-module-internet?ref=v1.0"
}

module "flux" {
  source = "github.com/getupcloud/terraform-module-flux?ref=v2.5.1"

  git_repo                = var.flux_git_repo
  manifests_path          = "./clusters/${var.cluster_name}/aks/manifests"
  wait                    = var.flux_wait
  flux_version            = var.flux_version
  manifests_template_vars = local.manifests_template_vars
  debug                   = var.dump_debug

}

module "teleport-agent" {
  source = "github.com/getupcloud/terraform-module-teleport-agent-config?ref=v0.3"

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

###### Network ######

locals {
  ## check if any of the required vars was provided
  user_subnet = (var.node_vnet_resource_group != null || var.node_vnet_name != null || var.node_subnet_name != null)
}

data "validation_error" "assert_subnet" {
  condition = local.user_subnet ? !(var.node_vnet_resource_group != null && var.node_vnet_name != null && var.node_subnet_name != null) : false
  summary   = "Either all or none of the vars node_vnet_resource_group, node_vnet_name, and node_subnet_name must be provided."
  details   = <<EOF
var.node_vnet_resource_group=${format("%#v", var.node_vnet_resource_group)}
var.node_vnet_name=${format("%#v", var.node_vnet_name)}
var.node_subnet_name=${format("%#v", var.node_subnet_name)}
EOF
}

data "azurerm_resource_group" "vnet" {
  count = local.user_subnet ? 1 : 0
  name  = var.node_vnet_resource_group
}

data "azurerm_virtual_network" "vnet" {
  count               = local.user_subnet ? 1 : 0
  name                = var.node_vnet_name
  resource_group_name = data.azurerm_resource_group.vnet[0].name
}

data "azurerm_subnet" "subnet" {
  count                = local.user_subnet ? 1 : 0
  name                 = var.node_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet[0].name
  resource_group_name  = data.azurerm_virtual_network.vnet[0].resource_group_name
}

##################

data "azuread_group" "aks_cluster_admins" {
  for_each     = toset(var.rbac_aad_admin_group_names)
  display_name = each.key
}

module "cluster" {
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/caruccio/terraform-azurerm-aks?ref=master"
  #source  = "Azure/aks/azurerm"
  #version = "4.14.0"

  depends_on = [
    azurerm_role_assignment.aks_private_dns_zone_user_assigned_identity_names,
    azurerm_role_assignment.aks_private_dns_zone_user_assigned_identity_ids,
    shell_script.pre_create
  ]

  admin_username            = var.admin_username
  client_id                 = var.client_id
  client_secret             = var.client_secret
  cluster_name              = var.cluster_name
  kubernetes_version        = var.kubernetes_version
  network_plugin            = var.network_policy == "azure" ? "azure" : var.network_plugin
  network_policy            = var.network_policy
  orchestrator_version      = var.default_node_pool.orchestrator_version != null ? var.default_node_pool.orchestrator_version : var.kubernetes_version
  prefix                    = var.prefix
  public_ssh_key            = var.public_ssh_key
  resource_group_name       = var.resource_group_name
  sku_tier                  = var.sku_tier
  tags                      = var.tags
  oidc_issuer_enabled       = var.oidc_issuer_enabled
  workload_identity_enabled = var.workload_identity_enabled

  private_cluster_enabled          = var.private_cluster_enabled
  api_server_authorized_ip_ranges  = var.private_cluster_enabled ? null : var.api_server_authorized_ip_ranges
  private_dns_zone_id              = var.private_dns_zone_enabled ? data.azurerm_private_dns_zone.aks[0].id : var.private_dns_zone_name
  http_application_routing_enabled = var.http_application_routing_enabled
  azure_policy_enabled             = var.azure_policy_enabled
  identity_type                    = var.identity_type
  identity_ids                     = local.identity_ids

  ## default nodepool
  default_node_pool_name = var.default_node_pool.name
  node_resource_group    = var.node_resource_group
  enable_auto_scaling    = var.default_node_pool.enable_auto_scaling
  min_count              = var.default_node_pool.min_count
  max_count              = var.default_node_pool.max_count
  node_count             = try(var.default_node_pool.node_count, null)
  max_pods               = var.default_node_pool.max_pods
  type                   = var.default_node_pool.type
  vm_size                = var.default_node_pool.vm_size
  zones                  = var.default_node_pool.zones
  node_labels            = var.default_node_pool.node_labels
  node_tags              = var.default_node_pool.node_tags
  node_taints            = var.default_node_pool.node_taints
  os_disk_size_gb        = var.default_node_pool.os_disk_size_gb
  os_disk_type           = var.default_node_pool.os_disk_type
  enable_node_public_ip  = var.default_node_pool.enable_node_public_ip
  enable_host_encryption = var.default_node_pool.enable_host_encryption
  vnet_subnet_id         = length(data.azurerm_subnet.subnet) > 0 ? data.azurerm_subnet.subnet[0].id : try(var.default_node_pool.vnet_subnet_id, null)
  dns_service_ip         = var.dns_service_ip
  docker_bridge_cidr     = var.docker_bridge_cidr
  outbound_type          = var.outbound_type
  service_cidr           = var.service_cidr
  pod_cidr               = var.network_plugin == "azure" ? null : var.pod_cidr

  enable_role_based_access_control = var.enable_role_based_access_control
  rbac_aad_managed                 = var.rbac_aad_managed
  rbac_aad_tenant_id               = var.rbac_aad_tenant_id

  # managed
  rbac_aad_admin_group_object_ids = local.rbac_aad_admin_group_object_ids
  # unmanaged
  rbac_aad_client_app_id     = var.rbac_aad_client_app_id
  rbac_aad_server_app_id     = var.rbac_aad_server_app_id
  rbac_aad_server_app_secret = var.rbac_aad_server_app_secret

  key_vault_secrets_provider_enabled = var.key_vault_secrets_provider_enabled
  key_vault_secrets_provider         = var.key_vault_secrets_provider

  ingress_application_gateway_enabled     = var.ingress_application_gateway_enabled
  ingress_application_gateway_name        = var.ingress_application_gateway_name
  ingress_application_gateway_id          = var.ingress_application_gateway_id
  ingress_application_gateway_subnet_cidr = var.ingress_application_gateway_subnet_cidr
  ingress_application_gateway_subnet_id   = var.ingress_application_gateway_subnet_id

  log_analytics_workspace_enabled = var.log_analytics_workspace_enabled
  log_analytics_workspace_name    = var.log_analytics_workspace_name
  log_analytics_workspace_sku     = var.log_analytics_workspace_sku
  log_retention_in_days           = var.log_retention_in_days

  allowed_maintenance_windows     = var.allowed_maintenance_windows
  not_allowed_maintenance_windows = var.not_allowed_maintenance_windows
}

resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  for_each = local.node_pools

  kubernetes_cluster_id  = module.cluster.aks_id
  name                   = each.key
  orchestrator_version   = var.default_node_pool.orchestrator_version != null ? var.default_node_pool.orchestrator_version : var.kubernetes_version
  enable_auto_scaling    = each.value.enable_auto_scaling
  min_count              = each.value.min_count
  max_count              = each.value.max_count
  node_count             = try(each.value.node_count, null)
  max_pods               = each.value.max_pods
  vm_size                = each.value.vm_size
  zones                  = each.value.zones
  node_labels            = each.value.node_labels
  node_taints            = each.value.node_taints
  os_disk_size_gb        = each.value.os_disk_size_gb
  os_disk_type           = each.value.os_disk_type
  enable_node_public_ip  = each.value.enable_node_public_ip
  enable_host_encryption = each.value.enable_host_encryption
  vnet_subnet_id         = length(data.azurerm_subnet.subnet) > 0 ? data.azurerm_subnet.subnet[0].id : try(var.default_node_pool.vnet_subnet_id, null)
  tags                   = merge(var.tags, try(each.value.node_tags, {}))

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
