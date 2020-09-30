resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [local.vnet_iprange]
}

resource "azurerm_subnet" "aci" {
  name                 = local.aci_subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.aci_subnet_iprange]
  delegation {
    name = "aci_delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
    }
  }
}
