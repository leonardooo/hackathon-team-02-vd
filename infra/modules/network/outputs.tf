output "vnet_id" {
  description = "ID da Virtual Network principal"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Nome da Virtual Network principal"
  value       = azurerm_virtual_network.main.name
}

output "app_subnet_id" {
  description = "ID da subnet de aplicação"
  value       = azurerm_subnet.app.id
}

output "db_subnet_id" {
  description = "ID da subnet do banco de dados (delegada para PostgreSQL)"
  value       = azurerm_subnet.db.id
}
