terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1"
    }

    kubernetes = {
      version = "~> 2.3.2"
    }

    random = {
      version = "~> 2"
    }

    azurerm = {
      version = ">= 3.0.0, < 4.0.0"
    }
  }
}
