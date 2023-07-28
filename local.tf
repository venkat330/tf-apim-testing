locals {
  global_constants = {
    brandHostMapping     = "{\"azure-api.net\" : \"azu1\"}"
    defaultSystemBrand   = "azu"
    sensitiveHeadersList = "Ocp-Apim-Subscription-Key,x-test-1,x-test-2"
  }
  sensitiveHeadersList = [
    "Ocp-Apim-Subscription-Key",
    "x-test-1",
    "x-test-2"
  ]

  cors = {
    allowedOrigins = [
      "https://azure-api.net"
    ]
    allowedHeaders = [
      "content-Type",
      "Content-length",
      "Accept",
      "Origin",
      "Access-control-Allow-credentials",
      "Authorization",
      "Accept-API-Version",
      "x-test-client",
      "x-test-brand",
      "x-test-channel",
    ]
    sensitiveHeadersList = [
      "Ocp-Apim-Subscription-Key",
      "x-test-1",
      "x-test-2"
    ]
    allowedMethods = [
      "GET",
      "POST",
      "PUT",
      "DELETE",
      "OPTIONS",
      "PATCH"
    ]

  }
  apimGlobalPolicybase = "${path.module}/policies/global-policy.xml"
  apiPolicyBase        = "${path.module}/policies/api-policy.xml"

  corsPolicyTemplate      = "${path.module}/templates/cors-template.tpl"
  sensitivePolicyTemplate = "${path.module}/templates/sensitive-template.tpl"
}