locals {
  identity_ids = concat(
    var.identity_ids,
    [for id in azurerm_user_assigned_identity.aks_cluster_user_assigned_identity : id.id]
  )
}

resource "azurerm_user_assigned_identity" "aks_cluster_user_assigned_identity" {
  for_each            = toset(var.identity_name != null ? [var.identity_name] : [])
  name                = each.key
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "aks_vnet_user_assigned_identity_names" {
  for_each = (var.private_dns_zone_enabled && local.has_user_assigned_identity) ? azurerm_user_assigned_identity.aks_cluster_user_assigned_identity : {}

  principal_id                     = each.value.principal_id
  role_definition_name             = "Network Contributor"
  scope                            = data.azurerm_virtual_network.node_vnet[0].id
  skip_service_principal_aad_check = var.private_dns_zone_skip_service_principal_aad_check
}

resource "azurerm_role_assignment" "aks_vnet_user_assigned_identity_ids" {
  for_each = toset((var.private_dns_zone_enabled && local.has_user_assigned_identity) ? var.identity_ids : [])

  principal_id                     = each.key
  role_definition_name             = "Network Contributor"
  scope                            = data.azurerm_virtual_network.node_vnet[0].id
  skip_service_principal_aad_check = var.private_dns_zone_skip_service_principal_aad_check
}

# This should be set by AKs itself when RG is created
#resource "azurerm_role_assignment" "aks_system_assigned_principal_id_node" {
#  count                            = var.node_resource_group != "" ? 1 : 0
#  principal_id                     = module.cluster.identity.principal_id
#  role_definition_name             = "Contributor"
#  scope                            = "/subscriptions/${var.subscription_id}/resourceGroups/${var.node_resource_group}"
#  skip_service_principal_aad_check = true
#}

resource "azurerm_role_assignment" "aks_system_assigned_principal_id_node_vnet" {
  count                            = var.node_vnet_resource_group != "" ? 1 : 0
  principal_id                     = module.cluster.identity.principal_id
  role_definition_name             = "Contributor"
  scope                            = data.azurerm_virtual_network.node_vnet[0].id
  skip_service_principal_aad_check = true
}
