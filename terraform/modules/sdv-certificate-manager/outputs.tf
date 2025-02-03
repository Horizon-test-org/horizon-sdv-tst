output "record_name_to_insert" {
  value = google_certificate_manager_dns_authorization.instance.dns_resource_record.0.name
}

output "record_type_to_insert" {
  value = google_certificate_manager_dns_authorization.instance.dns_resource_record.0.type
}

output "record_data_to_insert" {
  value = google_certificate_manager_dns_authorization.instance.dns_resource_record.0.data
}
