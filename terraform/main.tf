terraform {
  required_version = ">= 0.12"
  
  backend "azurerm" {
    environment = "public"
  }
}

provider "azurerm" {
  version = "~> 2.24"
  features {}
}

variable "resource_name" {
  type        = string
  description = "The name to use for Azure resources."
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be created."
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_name}-rg"
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                     = replace(var.resource_name, "-", "")
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "plan" {
  name                = "${var.resource_name}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
  kind             = "FunctionApp"
  is_xenon         = false
  per_site_scaling = false
  reserved         = false

  sku {
    tier     = "ElasticPremium"
    size     = "EP1"
    capacity = 1
  }
}

resource "azurerm_function_app" "app" {
  name                       = "${var.resource_name}-app"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
}