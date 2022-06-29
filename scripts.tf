resource "shell_script" "pre_create" {
  for_each = toset(var.pre_create)

  lifecycle_commands {
    create = each.value
    read   = null
    update = null
    delete = "echo {}"
  }

  environment = {}
}

resource "shell_script" "post_create" {
  for_each = toset(var.post_create)

  lifecycle_commands {
    create = each.value
    read   = null
    update = null
    delete = "echo {}"
  }

  environment = {}

  depends_on = [
    module.cluster.aks_id
  ]
}
