terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1"
    }

    kubernetes = {
      version = "~> 2.8"
    }

    random = {
      version = "~> 2"
    }

    azurerm = {
      version = ">= 3.0.0, < 4.0.0"
    }

    shell = {
      source  = "scottwinkler/shell"
      version = "~> 1"
    }

    validation = {
      source  = "tlkamp/validation"
      version = "~> 1"
    }
  }
}
