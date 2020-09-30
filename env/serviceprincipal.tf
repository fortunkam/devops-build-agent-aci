# Create an application
resource "azuread_application" "aci" {
  name = local.aci_sp_app_name
}

# Create a service principal
resource "azuread_service_principal" "aci" {
  application_id = azuread_application.aci.application_id
}

resource "random_string" "aci_password" {
keepers = {
    resource_group = azurerm_resource_group.rg.name
  }
  length = 32
  special = true
  override_special = "_%@"
}

resource "azuread_service_principal_password" "aci_password" {
  service_principal_id = azuread_service_principal.aci.id
  value                = random_string.aci_password.result
  end_date             = "2099-01-01T01:02:03Z"
}

resource "azurerm_role_assignment" "aci_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "acrpull"
  principal_id         = azuread_service_principal.aci.object_id
}

resource "azurerm_role_assignment" "aci_acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "acrpush"
  principal_id         = azuread_service_principal.aci.object_id
}