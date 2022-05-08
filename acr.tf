data "azurerm_container_registry" "acr" {
  provider = azurerm.acr
  count    = var.acr_name != "" ? 1 : 0

  name                = var.acr_name
  resource_group_name = var.acr_resource_group_name == "" ? var.subscription_id : var.acr_resource_group_name
}

resource "azurerm_role_assignment" "aks_acr" {
  provider = azurerm.acr
  count    = var.acr_name != "" ? 1 : 0

  principal_id                     = module.cluster.kubelet_identity.principal_id
  role_definition_name             = var.acr_role_definition_name
  scope                            = data.azurerm_container_registry.acr[0].id
  skip_service_principal_aad_check = var.acr_skip_service_principal_aad_check
}
