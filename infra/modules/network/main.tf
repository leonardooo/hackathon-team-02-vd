resource "azurerm_virtual_network" "main" {
  name                = "sifap-${var.environment}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  lifecycle {
    # Previne destruição acidental da VNet em produção
    prevent_destroy = false # altere para true em prod
  }
}

resource "azurerm_subnet" "app" {
  name                 = "sifap-${var.environment}-app-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = "sifap-${var.environment}-db-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
  # Delegação para PostgreSQL Flexible Server
  delegation {
    name = "postgres-delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
