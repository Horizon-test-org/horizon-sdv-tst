
data "google_project" "project" {}

resource "google_project_iam_member" "storage_object_viewer" {
  project = data.google_project.project.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${var.sdv_default_computer_sa}"
}

module "sdv_apis" {
  source = "../sdv-apis"

  list_of_apis = var.sdv_list_of_apis
}

module "sdv_secrets" {
  source = "../sdv-secrets"

  location        = var.sdv_location
  gcp_secrets_map = var.sdv_gcp_secrets_map
}

module "sdv_wi" {
  source = "../sdv-wi"

  wi_service_accounts = var.sdv_wi_service_accounts
}

module "sdv_gcs" {
  source = "../sdv-gcs"

  bucket_name = "${data.google_project.project.project_id}-aaos"
  location    = var.sdv_location
}

module "sdv_network" {
  source = "../sdv-network"

  network     = var.sdv_network
  subnetwork  = var.sdv_subnetwork
  region      = var.sdv_region
  router_name = var.sdv_network_egress_router_name
}

module "sdv_bastion_host" {
  source = "../sdv-bastion-host"
  depends_on = [
    module.sdv_apis,
    module.sdv_network
  ]

  host_name       = var.sdv_bastion_host_name
  service_account = var.sdv_bastion_host_sa
  network         = var.sdv_network
  subnetwork      = var.sdv_subnetwork
  zone            = var.sdv_zone
  members         = var.sdv_bastion_host_members
}

module "sdv_gke_cluster" {
  source = "../sdv-gke-cluster"
  depends_on = [
    module.sdv_apis,
    module.sdv_bastion_host,
    module.sdv_gcs,
    module.sdv_wi,
  ]

  project_id      = data.google_project.project.project_id
  cluster_name    = var.sdv_cluster_name
  location        = var.sdv_location
  network         = var.sdv_network
  subnetwork      = var.sdv_subnetwork
  service_account = var.sdv_default_computer_sa

  # Default node pool configuration
  node_pool_name = var.sdv_cluster_node_pool_name
  machine_type   = var.sdv_cluster_node_pool_machine_type
  node_count     = var.sdv_cluster_node_pool_count

  # build node pool configuration
  build_node_pool_name           = var.sdv_build_node_pool_name
  build_node_pool_node_count     = var.sdv_build_node_pool_node_count
  build_node_pool_machine_type   = var.sdv_build_node_pool_machine_type
  build_node_pool_min_node_count = var.sdv_build_node_pool_min_node_count
  build_node_pool_max_node_count = var.sdv_build_node_pool_max_node_count
}

module "sdv_artifact_registry" {
  source = "../sdv-artifact-registry"

  repository_id  = var.sdv_artifact_registry_repository_id
  location       = var.sdv_location
  members        = var.sdv_artifact_registry_repository_members
  reader_members = var.sdv_artifact_registry_repository_reader_members
}

module "sdv_certificate_manager" {
  source = "../sdv-certificate-manager"

  name       = var.sdv_ssl_certificate_name
  domain     = var.sdv_ssl_certificate_domain
  depends_on = [module.sdv_apis]
}

# module "sdv_cuttlefish_image_template" {
#   source = "../sdv-custom-image"

#   image_name            = "cuttlefish-image-template"
#   compute_instance_name = "cuttlefish-image-template-ci"
#   machine_type          = "n1-standard-1"
#   zone                  = var.sdv_zone
#   base_image            = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
#   network               = var.sdv_network
#   subnetwork            = var.sdv_subnetwork
#   snapshot_name         = "cuttlefish-image-template-snapshot"
#   storage_locations     = ["europe-west1"]
#   custom_image_family   = "ubuntu-with-gcloud"

#   metadata_startup_script = <<-EOT
#     #!/bin/bash
#     echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
#     curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
#     sudo apt-get update && sudo apt-get install google-cloud-sdk -y
#     # TODO: Install Cuttlefish
#   EOT

# }

#
# Can create it only after deploy keycloack
#
# module "sdv_apis_services" {
#   source     = "../sdv-apis-services"
#   depends_on = [module.sdv_apis]

#   project                  = var.sdv_project
#   auth_config_location     = var.sdv_location
#   auth_config_display_name = var.sdv_auth_config_display_name
#   auth_config_endpoint_uri = var.sdv_auth_config_endpoint_uri
# }

module "sdv_ssl_policy" {
  source = "../sdv-ssl-policy"

  name            = "gke-ssl-policy"
  min_tls_version = "TLS_1_2"
  profile         = "RESTRICTED"
}

module "sdv_gcs_scripts" {
  source = "../sdv-gcs"

  bucket_name = "${data.google_project.project.project_id}-scripts"
  location    = var.sdv_location
}

module "sdv_copy_to_bastion_host" {
  source = "../sdv-copy-to-bastion-host"

  bastion_host            = var.sdv_bastion_host_name
  file                    = "../../bash-scripts/horizon-stage-01.sh"
  destination_path        = "~/bash-scripts/horizon-stage-01.sh"
  zone                    = var.sdv_zone
  location                = var.sdv_location
  bucket_name             = "${data.google_project.project.project_id}-scripts"
  bucket_destination_path = "bash-scripts/horizon-stage-01.sh"

  depends_on = [
    module.sdv_bastion_host,
    module.sdv_gcs_scripts
  ]
}

module "sdv_bash_on_bastion_host" {
  source = "../sdv-bash-on-bastion-host"

  bastion_host = var.sdv_bastion_host_name
  zone         = var.sdv_zone
  command      = var.sdv_bastion_host_bash_command

  depends_on = [
    module.sdv_bastion_host,
    module.sdv_gke_cluster,
    module.sdv_copy_to_bastion_host,
  ]
}
