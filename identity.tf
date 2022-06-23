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
