locals {
  global_constants = {
    brandHostMapping     = "{\"azure-api.net\" : \"azu1\"}"
    defaultSystemBrand         = "azu"
    sensitiveHeadersList = "Ocp-Apim-Subscription-Key,x-test-1,x-test-2"
  }
  apim_global_policy_xml_content = "${path.module}/policies/global-policy.xml"
  api_policy_xml_content = "${path.module}/policies/api-policy.xml"
}