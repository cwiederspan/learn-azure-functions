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

variable "cosmos_ip_range_filter" {
  type        = string
  description = "A comma separated list of CIDR block strings that can access the Cosmos DB data."
  # default     = null
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_name}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "web" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.AzureCosmosDB"]

  delegation {
    name = "web-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "data" {
  name                 = "data-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.10.0/24"]

  enforce_private_link_endpoint_network_policies = true
  # enforce_private_link_service_network_policies  = true
}

resource "azurerm_storage_account" "storage" {
  name                     = replace(var.resource_name, "-", "")
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_cosmosdb_account" "cosmos" {
  name                = "${var.resource_name}-cosmos"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_automatic_failover         = false
  is_virtual_network_filter_enabled = true

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }

  virtual_network_rule {
    id = azurerm_subnet.web.id
  }

  ip_range_filter = var.cosmos_ip_range_filter
}

resource "azurerm_cosmosdb_sql_database" "database" {
  name                = "MyDatabase"
  account_name        = azurerm_cosmosdb_account.cosmos.name
  resource_group_name = azurerm_cosmosdb_account.cosmos.resource_group_name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "data" {
  name                = "MyData"
  account_name        = azurerm_cosmosdb_account.cosmos.name
  resource_group_name = azurerm_cosmosdb_account.cosmos.resource_group_name
  database_name       = azurerm_cosmosdb_sql_database.database.name
  partition_key_path  = "/id"
  throughput          = 400
}

resource "azurerm_app_service_plan" "plan" {
  name                = "${var.resource_name}-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  
  kind             = "elastic"  # "linux"
  is_xenon         = false
  per_site_scaling = false
  reserved         = true

  # maximum_elastic_worker_count = 5

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
  os_type                    = "linux"
  version                    = "~3"

  app_settings = {
    WEBSITE_CONTENTSHARE                     = "${var.resource_name}-app-00001"
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = "${azurerm_storage_account.storage.primary_connection_string}"

    FUNCTIONS_WORKER_RUNTIME    = "dotnet"
    # FUNCTIONS_EXTENSION_VERSION = "~3"

    WEBSITE_RUN_FROM_PACKAGE            = true
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = true
    WEBSITE_ENABLE_SYNC_UPDATE_SITE     = true

    CosmosDBConnection = "${azurerm_cosmosdb_account.cosmos.connection_strings[0]}"
  }
}

resource "azurerm_private_endpoint" "endpoint" {
  name                = "${var.resource_name}-privatelink"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.data.id

  private_service_connection {
    name                           = "${var.resource_name}-privatelink-connection"
    private_connection_resource_id = azurerm_cosmosdb_account.cosmos.id
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.resource_name}-privatelink-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns.id]
  }
}

resource "azurerm_private_dns_zone" "dns" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_app_service_virtual_network_swift_connection" "injection" {
  app_service_id = azurerm_function_app.app.id
  subnet_id      = azurerm_subnet.web.id
}