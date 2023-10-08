# Creates a resource group for FlixTube in your Azure account.
resource "azurerm_resource_group" "flixtube" {
  name     = var.app_name
  location = var.location
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                       = "ender0000kv"
  location                   = azurerm_resource_group.flixtube.location
  resource_group_name        = azurerm_resource_group.flixtube.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}

//store secrets to key vault
resource "azurerm_key_vault_secret" "store_value" {
  name         = "clientsecret"
  value        = var.client_secret
  key_vault_id = azurerm_key_vault.kv.id
}

//connect to key vault
data "azurerm_key_vault" "connect_to_kv" {
  name                = "ender0000kv"
  resource_group_name = azurerm_resource_group.flixtube.name
  depends_on          = [azurerm_key_vault.kv]
}

//get value from key vault
data "azurerm_key_vault_secret" "get_value" {
  name         = "clientsecret"
  key_vault_id = data.azurerm_key_vault.connect_to_kv.id
  depends_on   = [azurerm_key_vault_secret.store_value]
}

//display the value
output "secret_value" {
  value     = data.azurerm_key_vault_secret.get_value.value
  sensitive = true
}