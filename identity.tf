locals {
  # Unify user assigned identities to be used as either `id` or `principal_id` (
  # TODO: read principal_id for var.identity_ids
  identities = concat(var.identity_ids != null ? [for id in var.identity_ids : {
    id           = id
    principal_id = ""
    }] : [],
    [
      for id in azurerm_user_assigned_identity.aks_cluster_user_assigned_identity : {
        id           = id.id
        principal_id = id.principal_id
      }
  ])
}

resource "azurerm_user_assigned_identity" "aks_cluster_user_assigned_identity" {
  for_each            = toset(var.identity_name != null ? [var.identity_name] : [])
  name                = each.key
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  tags                = var.tags
}
