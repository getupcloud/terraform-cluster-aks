data "azurerm_private_dns_zone" "aks" {
  provider = azurerm.private_dns_zone
  count    = var.private_dns_zone_enabled ? 1 : 0

  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name == "" ? var.resource_group_name : var.private_dns_zone_resource_group_name
}

resource "azurerm_role_assignment" "aks_private_dns_zone" {
  provider = azurerm.acr
  count    = var.private_dns_zone_enabled ? 1 : 0

  principal_id                     = var.user_assigned_identity_id ? var.user_assigned_identity_id : module.cluster.system_assigned_identity.principal_id
  role_definition_name             = var.private_dns_zone_role_definition_name
  scope                            = data.azurerm_private_dns_zone.aks[0].id
  skip_service_principal_aad_check = var.private_dns_zone_skip_service_principal_aad_check
}
