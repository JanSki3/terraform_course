terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.86.0"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "devops-rg" {
  name     = "rg-terraform"
  location = "West Europe"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_storage_account" "devops-sa" {
  name                = "storeforstatic"
  resource_group_name = azurerm_resource_group.devops-rg.name
  location            = azurerm_resource_group.devops-rg.location

  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  enable_https_traffic_only = true
  static_website {
    index_document = "index.html"
  }
}

resource "azurerm_service_plan" "devops-sp" {
  name                = "serviceplanforstatic"
  resource_group_name = azurerm_resource_group.devops-rg.name
  location            = azurerm_resource_group.devops-rg.location
  sku_name            = "P1v2"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "devops-wa" {
  name                = "wa-terraform"
  resource_group_name = azurerm_resource_group.devops-rg.name
  location            = azurerm_service_plan.devops-sp.location
  service_plan_id     = azurerm_service_plan.devops-sp.id

  site_config {}
}

resource "azurerm_storage_blob" "devops_blob" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.devops-sa.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source_content         = file("index.html")
}