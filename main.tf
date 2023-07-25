terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Root module should specify the maximum provider version
      # The ~> operator is a convenient shorthand for allowing only patch releases within a specific minor release.
      version = "~> 3.60"
    }
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "resource_group" {
  name     = "${var.project}-${var.environment}-resource-group"
  location = var.location
}
resource "azurerm_api_management" "api_management" {
  name                = "${var.project}-${var.environment}-api-management"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  publisher_name      = "Venkat"
  publisher_email     = "venkat.330.aws@gmail.c0m"
  sku_name            = "Developer_1" # Support for Consumption_0 arrives in hashicorp/azurerm v2.42.0
}
resource "azurerm_api_management_api" "api_management_api_public" {
  name                = "${var.project}-${var.environment}-api-management-api-public"
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = azurerm_resource_group.resource_group.name
  revision            = "1"
  display_name        = "Public"
  path                = ""
  protocols           = ["https"]
  # service_url           = "https://httpbin.org/status/200"
  subscription_required = false
}
resource "azurerm_api_management_named_value" "global_constants" {
  for_each            = local.global_constants
  name                = each.key
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = azurerm_resource_group.resource_group.name
  display_name        = each.key
  value               = each.value
}
resource "azurerm_api_management_product" "api_product" {
  product_id            = "test-product"
  api_management_name   = azurerm_api_management.api_management.name
  resource_group_name   = azurerm_resource_group.resource_group.name
  display_name          = "test-product"
  subscription_required = true
  subscriptions_limit   = 10
  approval_required     = false
  published             = true
}
resource "azurerm_api_management_api" "health_api" {
  name                = "health"
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = azurerm_resource_group.resource_group.name
  revision            = "1"
  display_name        = "health"
  protocols           = ["https"]
  # version = "v1"
  path                  = "health"
  subscription_required = true
  import {
    content_format = "openapi"
    content_value  = file("${path.root}/specs/healthcheck.xml")
  }
}
# resource "azurerm_api_management_api_version_set" "api_version" {
#   name = "apim_version"
#   api_management_name = azurerm_api_management.api_management.name
#   resource_group_name = azurerm_resource_group.resource_group.name
#   display_name = "apim_version"
#   versioning_scheme = "Segment"
# }
locals {
  globalPolicyData = file(local.apimGlobalPolicybase)

  corsPolicyData = templatefile(local.corsPolicyTemplate, {
    allowedHeaders = setunion(local.cors.allowedHeaders, local.sensitiveHeadersList)
    allowedOrigins = local.cors.allowedOrigins,
    allowedMethods = local.cors.allowedMethods,
  })

  sensitivePolicyData = templatefile(local.sensitivePolicyTemplate, {
    sensitiveHeaders = local.sensitiveHeadersList,
  })

  globalPolicyWithCors = replace(local.globalPolicyData,
  "<!-- <cors-placeholder/> -->", local.corsPolicyData)
  globalPolicyFinal = replace(local.globalPolicyWithCors,
  "<!-- <sensitive-placeholder/> -->", local.sensitivePolicyData)

}


resource "azurerm_api_management_policy" "global_policy" {
  api_management_id = azurerm_api_management.api_management.id

  xml_content = local.globalPolicyFinal
  depends_on = [azurerm_api_management_named_value.global_constants,
    local.globalPolicyFinal,
  ]
}
resource "azurerm_api_management_api_policy" "api_policy" {
  api_name            = azurerm_api_management_api.health_api.name
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = azurerm_resource_group.resource_group.name
  xml_content         = file(local.apiPolicyBase)
  depends_on          = [azurerm_api_management_named_value.global_constants]
}
resource "azurerm_api_management_product_policy" "api_product_policy" {
  product_id          = azurerm_api_management_product.api_product.product_id
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = azurerm_resource_group.resource_group.name
  xml_content         = templatefile("${path.root}/policies/prod-policy.xml", {})
}


# data "http" "openapi_spec" {
#   url = "https://raw.githubusercontent.com/OpenAPITools/openapi-generator/master/modules/openapi-generator/src/test/resources/3_0/petstore.yaml"
# }

# resource "azurerm_api_management_api" "proxy_api" {
#   name                = "proxy-api"
#   api_management_name = azurerm_api_management.api_management.name
#   resource_group_name = azurerm_resource_group.resource_group.name
#   display_name        = "Proxy API"
#   path                = "proxy"
#   protocols           = ["https"]
#   revision            = "1"
#   subscription_required = false

#   # revision {
#   #   version    = "1"
#   #   description = "Initial version"
#   # }

#   # Import OpenAPI spec for the API
#   import {
#     content_format = "openapi+json"
#     content_value  = data.http.openapi_spec.body
#   }
# }

# resource "azurerm_api_management_api_operation" "proxy_operation" {
#   name                = "proxy-operation"
#   api_name            = azurerm_api_management_api.proxy_api.name
#   api_management_name = azurerm_api_management.api_management.name
#   display_name        = "Proxy Operation"
#   method              = "GET"
#   url_template        = "/get/{*path}"

#   # Define the backend service settings
#   policy = <<POLICY
#     <policies>
#       <inbound>
#         <base />
#       </inbound>
#       <backend>
#         <base />
#         <set-backend-service base-url="https://httpbin.org" />
#       </backend>
#       <outbound>
#         <base />
#       </outbound>
#     </policies>
#   POLICY
# }