output "enabled_apis" {
  description = "List of enabled APIs."
  value       = [for api in google_project_service.required_apis : api.service]
}

output "apis_ready" {
  description = "Indicates when all APIs are enabled and ready."
  value       = true
  depends_on  = [google_project_service.required_apis]
}
