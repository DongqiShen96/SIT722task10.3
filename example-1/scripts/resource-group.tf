# Creates a resource group for FlixTube in your Azure account.

resource "azurerm_resource_group" "flixtube" {
  name     = "flixtubeExample1DQS"
  location = "Australia Southeast"
}
