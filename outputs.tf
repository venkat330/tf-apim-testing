# output "function_app_name" {
#   value = azurerm_function_app.function_app.name
#   description = "Deployed function app name"
# }

# output "function_app_default_hostname" {
#   value = azurerm_function_app.function_app.default_hostname
#   description = "Deployed function app hostname"
# }

output "api_management_gateway_url" {
  value       = azurerm_api_management.api_management.gateway_url
  description = "APIM instance gateway hostname"
}

output "api_management_portal_url" {
  description = "The URL for the Publisher Portal associated with this API Management service"
  value       = azurerm_api_management.api_management.portal_url
}
