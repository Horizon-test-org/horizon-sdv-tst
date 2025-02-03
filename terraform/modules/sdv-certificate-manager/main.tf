data "google_project" "project" {}

resource "google_certificate_manager_certificate" "horizon_sdv_cert" {
  project = data.google_project.project.project_id
  name    = var.name
  scope   = "DEFAULT"
  managed {
    domains = [
      google_certificate_manager_dns_authorization.instance.domain
    ]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.instance.id
    ]
  }
}

resource "google_certificate_manager_dns_authorization" "instance" {
  name   = "horizon-sdv-dns-auth"
  domain = var.domain
}

resource "google_certificate_manager_certificate_map" "horizon_sdv_map" {
  project     = data.google_project.project.project_id
  name        = "horizon-sdv-map"
  description = "Certificate Manager Map for Horizon SDV"
}

resource "google_certificate_manager_certificate_map_entry" "horizon_sdv_map_entry" {
  name         = "horizon-sdv-map-entry"
  description  = "Certificate Manager Map Entry for Horizon SDV"
  map          = google_certificate_manager_certificate_map.horizon_sdv_map.name
  certificates = [google_certificate_manager_certificate.horizon_sdv_cert.id]
  matcher      = "PRIMARY"
}

