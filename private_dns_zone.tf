data "azurerm_private_dns_zone" "aks" {
  provider = azurerm.private_dns_zone
  count    = var.private_dns_zone_enabled ? 1 : 0

  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name == "" ? var.resource_group_name : var.private_dns_zone_resource_group_name
}

locals {
  has_user_assigned_identity   = (try(regex("\\bUserAssigned\\b", var.identity_type), "") == "UserAssigned")
  has_system_assigned_identity = (try(regex("\\bSystemAssigned\\b", var.identity_type), "") == "SystemAssigned")
}

# SystemAssigned identity cant be used by for_each/count loops because planning must known it's value before planning itself,
# thus we must split user/system assigned identities into two separated azurerm_role_assignment resources.

resource "azurerm_role_assignment" "aks_private_dns_zone_system_assigned_identity" {
  provider = azurerm.private_dns_zone
  for_each = toset((var.private_dns_zone_enabled && local.has_system_assigned_identity) ? ["SystemAssigned"] : [])

  principal_id                     = module.cluster.cluster_identity.principal_id
  role_definition_name             = var.private_dns_zone_role_definition_name
  scope                            = data.azurerm_private_dns_zone.aks[0].id
  skip_service_principal_aad_check = var.private_dns_zone_skip_service_principal_aad_check
}

resource "azurerm_role_assignment" "aks_private_dns_zone_user_assigned_identity_names" {
  provider = azurerm.private_dns_zone
  for_each = (var.private_dns_zone_enabled && local.has_user_assigned_identity) ? azurerm_user_assigned_identity.aks_cluster_user_assigned_identity : {}

  principal_id                     = each.value.principal_id
  role_definition_name             = var.private_dns_zone_role_definition_name
  scope                            = data.azurerm_private_dns_zone.aks[0].id
  skip_service_principal_aad_check = var.private_dns_zone_skip_service_principal_aad_check
}

resource "azurerm_role_assignment" "aks_private_dns_zone_user_assigned_identity_ids" {
  provider = azurerm.private_dns_zone
  for_each = toset((var.private_dns_zone_enabled && local.has_user_assigned_identity) ? var.identity_ids : [])

  principal_id                     = each.key
  role_definition_name             = var.private_dns_zone_role_definition_name
  scope                            = data.azurerm_private_dns_zone.aks[0].id
  skip_service_principal_aad_check = var.private_dns_zone_skip_service_principal_aad_check
}
