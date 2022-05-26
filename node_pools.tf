resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  for_each = local.node_pools

  kubernetes_cluster_id  = module.cluster.aks_id
  name                   = each.key
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
  vnet_subnet_id         = each.value.vnet_subnet_id
  tags                   = merge(var.tags, try(each.value.node_tags, {}))

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
