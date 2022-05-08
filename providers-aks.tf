provider "azurerm" {
  subscription_id = var.subscription_id

  features {}
}

# Configure the Azure Resource Manager Provider for private DNS zones subscription
provider "azurerm" {
  alias           = "private_dns_zone"
  subscription_id = var.private_dns_zone_subscription_id == "" ? var.subscription_id : var.private_dns_zone_subscription_id

  features {}
}

# Configure the Azure Resource Manager Provider for Azure container registry subscription
provider "azurerm" {
  alias           = "acr"
  subscription_id = var.acr_subscription_id == "" ? var.subscription_id : var.acr_subscription_id

  features {}
}

