output "sp_password" {
  value = random_string.aci_password.result
}

output "sp_app_id" {
  value = azuread_application.aci.application_id
}

output "sp_object_id" {
  value = azuread_application.aci.object_id
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "subnet_id" {
  value = azurerm_subnet.aci.id
}