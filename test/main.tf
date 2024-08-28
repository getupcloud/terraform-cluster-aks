terraform {
  required_providers {
    azurerm = {
      version = ">= 3.0.0, < 4.0.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1"
    }

    kubernetes = {
      version = "~> 2.8"
    }

    kustomization = {
      source  = "kbst/kustomization"
      version = "< 1"
    }

    random = {
      version = "~> 2"
    }

    shell = {
      source  = "scottwinkler/shell"
      version = "~> 1"
    }
  }
}

provider "kustomization" {
  kubeconfig_raw = ""
}

provider "azurerm" {
  skip_provider_registration = true
  subscription_id            = var.subscription_id
  tenant_id                  = var.tenant_id
  client_id                  = var.client_id
  client_secret              = var.client_secret

  features {}
}


module "cluster" {
  source = "../"

  cluster_name = "cluster_name"
  customer_name = "customer_name"

  resource_group_name = "resource_group_name"
  subscription_id = "subscription_id"
}
