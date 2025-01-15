## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.6 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 6.10.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | 6.10.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.10.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sdv_apis"></a> [sdv\_apis](#module\_sdv\_apis) | ../sdv-apis | n/a |
| <a name="module_sdv_artifact_registry"></a> [sdv\_artifact\_registry](#module\_sdv\_artifact\_registry) | ../sdv-artifact-registry | n/a |
| <a name="module_sdv_bash_on_bastion_host"></a> [sdv\_bash\_on\_bastion\_host](#module\_sdv\_bash\_on\_bastion\_host) | ../sdv-bash-on-bastion-host | n/a |
| <a name="module_sdv_bastion_host"></a> [sdv\_bastion\_host](#module\_sdv\_bastion\_host) | ../sdv-bastion-host | n/a |
| <a name="module_sdv_certificate_manager"></a> [sdv\_certificate\_manager](#module\_sdv\_certificate\_manager) | ../sdv-certificate-manager | n/a |
| <a name="module_sdv_copy_to_bastion_host"></a> [sdv\_copy\_to\_bastion\_host](#module\_sdv\_copy\_to\_bastion\_host) | ../sdv-copy-to-bastion-host | n/a |
| <a name="module_sdv_gcs"></a> [sdv\_gcs](#module\_sdv\_gcs) | ../sdv-gcs | n/a |
| <a name="module_sdv_gcs_scripts"></a> [sdv\_gcs\_scripts](#module\_sdv\_gcs\_scripts) | ../sdv-gcs | n/a |
| <a name="module_sdv_gke_cluster"></a> [sdv\_gke\_cluster](#module\_sdv\_gke\_cluster) | ../sdv-gke-cluster | n/a |
| <a name="module_sdv_iam_compute_instance_admin"></a> [sdv\_iam\_compute\_instance\_admin](#module\_sdv\_iam\_compute\_instance\_admin) | ../sdv-iam | n/a |
| <a name="module_sdv_iam_compute_network_admin"></a> [sdv\_iam\_compute\_network\_admin](#module\_sdv\_iam\_compute\_network\_admin) | ../sdv-iam | n/a |
| <a name="module_sdv_iam_gcs_users"></a> [sdv\_iam\_gcs\_users](#module\_sdv\_iam\_gcs\_users) | ../sdv-iam | n/a |
| <a name="module_sdv_iam_gcs_viewers"></a> [sdv\_iam\_gcs\_viewers](#module\_sdv\_iam\_gcs\_viewers) | ../sdv-iam | n/a |
| <a name="module_sdv_iam_sceret_manager"></a> [sdv\_iam\_sceret\_manager](#module\_sdv\_iam\_sceret\_manager) | ../sdv-iam | n/a |
| <a name="module_sdv_iam_secured_tunnel_user"></a> [sdv\_iam\_secured\_tunnel\_user](#module\_sdv\_iam\_secured\_tunnel\_user) | ../sdv-iam | n/a |
| <a name="module_sdv_iam_service_account_user"></a> [sdv\_iam\_service\_account\_user](#module\_sdv\_iam\_service\_account\_user) | ../sdv-iam | n/a |
| <a name="module_sdv_network"></a> [sdv\_network](#module\_sdv\_network) | ../sdv-network | n/a |
| <a name="module_sdv_sa_key_secret_gce_creds"></a> [sdv\_sa\_key\_secret\_gce\_creds](#module\_sdv\_sa\_key\_secret\_gce\_creds) | ../sdv-sa-key-secret | n/a |
| <a name="module_sdv_secrets"></a> [sdv\_secrets](#module\_sdv\_secrets) | ../sdv-secrets | n/a |
| <a name="module_sdv_ssl_policy"></a> [sdv\_ssl\_policy](#module\_sdv\_ssl\_policy) | ../sdv-ssl-policy | n/a |
| <a name="module_sdv_wi"></a> [sdv\_wi](#module\_sdv\_wi) | ../sdv-wi | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow_tcp_22](https://registry.terraform.io/providers/hashicorp/google/6.10.0/docs/resources/compute_firewall) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/6.10.0/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sdv_artifact_registry_repository_id"></a> [sdv\_artifact\_registry\_repository\_id](#input\_sdv\_artifact\_registry\_repository\_id) | Define the name of the artifact registry repository name | `string` | n/a | yes |
| <a name="input_sdv_artifact_registry_repository_members"></a> [sdv\_artifact\_registry\_repository\_members](#input\_sdv\_artifact\_registry\_repository\_members) | List of members allowed to write access the artifact registry | `list(string)` | n/a | yes |
| <a name="input_sdv_artifact_registry_repository_reader_members"></a> [sdv\_artifact\_registry\_repository\_reader\_members](#input\_sdv\_artifact\_registry\_repository\_reader\_members) | List of members allowed to reader access the artifact registry | `list(string)` | n/a | yes |
| <a name="input_sdv_auth_config_display_name"></a> [sdv\_auth\_config\_display\_name](#input\_sdv\_auth\_config\_display\_name) | Define the auth config display name | `string` | n/a | yes |
| <a name="input_sdv_auth_config_endpoint_uri"></a> [sdv\_auth\_config\_endpoint\_uri](#input\_sdv\_auth\_config\_endpoint\_uri) | Define the auth config endpont URI | `string` | n/a | yes |
| <a name="input_sdv_bastion_host_bash_command"></a> [sdv\_bastion\_host\_bash\_command](#input\_sdv\_bastion\_host\_bash\_command) | Define the commands to run on the bastion host | `string` | n/a | yes |
| <a name="input_sdv_bastion_host_members"></a> [sdv\_bastion\_host\_members](#input\_sdv\_bastion\_host\_members) | List of members allowed to access the bastion server | `list(string)` | n/a | yes |
| <a name="input_sdv_bastion_host_name"></a> [sdv\_bastion\_host\_name](#input\_sdv\_bastion\_host\_name) | Name of the bastion host server | `string` | n/a | yes |
| <a name="input_sdv_bastion_host_sa"></a> [sdv\_bastion\_host\_sa](#input\_sdv\_bastion\_host\_sa) | SA used by the bastion host and allow IAP to the host | `string` | n/a | yes |
| <a name="input_sdv_build_node_pool_machine_type"></a> [sdv\_build\_node\_pool\_machine\_type](#input\_sdv\_build\_node\_pool\_machine\_type) | Type fo the machine for the build node pool | `string` | `"c2d-highcpu-112"` | no |
| <a name="input_sdv_build_node_pool_max_node_count"></a> [sdv\_build\_node\_pool\_max\_node\_count](#input\_sdv\_build\_node\_pool\_max\_node\_count) | Number of max of nodes for the build node pool | `number` | `20` | no |
| <a name="input_sdv_build_node_pool_min_node_count"></a> [sdv\_build\_node\_pool\_min\_node\_count](#input\_sdv\_build\_node\_pool\_min\_node\_count) | Number of minimum of nodes for the build node pool | `number` | `0` | no |
| <a name="input_sdv_build_node_pool_name"></a> [sdv\_build\_node\_pool\_name](#input\_sdv\_build\_node\_pool\_name) | Name of the build node pool | `string` | `"sdv-build-node-pool"` | no |
| <a name="input_sdv_build_node_pool_node_count"></a> [sdv\_build\_node\_pool\_node\_count](#input\_sdv\_build\_node\_pool\_node\_count) | Number of nodes for the build node pool | `number` | `0` | no |
| <a name="input_sdv_cluster_name"></a> [sdv\_cluster\_name](#input\_sdv\_cluster\_name) | Name of the cluster | `string` | n/a | yes |
| <a name="input_sdv_cluster_node_pool_count"></a> [sdv\_cluster\_node\_pool\_count](#input\_sdv\_cluster\_node\_pool\_count) | Define the number of nodes for the node pool | `number` | `1` | no |
| <a name="input_sdv_cluster_node_pool_machine_type"></a> [sdv\_cluster\_node\_pool\_machine\_type](#input\_sdv\_cluster\_node\_pool\_machine\_type) | Define the machine type of the node pool | `string` | `"n1-standard-4"` | no |
| <a name="input_sdv_cluster_node_pool_name"></a> [sdv\_cluster\_node\_pool\_name](#input\_sdv\_cluster\_node\_pool\_name) | Name of the cluster node pool | `string` | n/a | yes |
| <a name="input_sdv_default_computer_sa"></a> [sdv\_default\_computer\_sa](#input\_sdv\_default\_computer\_sa) | The default Computer SA | `string` | n/a | yes |
| <a name="input_sdv_gcp_secrets_map"></a> [sdv\_gcp\_secrets\_map](#input\_sdv\_gcp\_secrets\_map) | A map of secrets with their IDs and values. | <pre>map(object({<br/>    secret_id        = string<br/>    value            = string<br/>    use_github_value = bool<br/>    gke_access = list(object({<br/>      ns = string<br/>      sa = string<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_sdv_list_of_apis"></a> [sdv\_list\_of\_apis](#input\_sdv\_list\_of\_apis) | List of APIs for the project | `set(string)` | n/a | yes |
| <a name="input_sdv_location"></a> [sdv\_location](#input\_sdv\_location) | Define the default location for the project, should be the same as the region value | `string` | n/a | yes |
| <a name="input_sdv_network"></a> [sdv\_network](#input\_sdv\_network) | Define the name of the VPC network | `string` | n/a | yes |
| <a name="input_sdv_network_egress_router_name"></a> [sdv\_network\_egress\_router\_name](#input\_sdv\_network\_egress\_router\_name) | Define the name of the egress router of the network | `string` | n/a | yes |
| <a name="input_sdv_project"></a> [sdv\_project](#input\_sdv\_project) | Define the GCP project id | `string` | n/a | yes |
| <a name="input_sdv_region"></a> [sdv\_region](#input\_sdv\_region) | Define the default region for the project | `string` | n/a | yes |
| <a name="input_sdv_ssl_certificate_domain"></a> [sdv\_ssl\_certificate\_domain](#input\_sdv\_ssl\_certificate\_domain) | Define the SSL Certificate domain name | `string` | n/a | yes |
| <a name="input_sdv_ssl_certificate_name"></a> [sdv\_ssl\_certificate\_name](#input\_sdv\_ssl\_certificate\_name) | Define the SSL Certificate name | `string` | `"horizon-sdv"` | no |
| <a name="input_sdv_subnetwork"></a> [sdv\_subnetwork](#input\_sdv\_subnetwork) | Define the subnet name | `string` | n/a | yes |
| <a name="input_sdv_target_https_proxy_name"></a> [sdv\_target\_https\_proxy\_name](#input\_sdv\_target\_https\_proxy\_name) | Define the HTTPs proxy name | `string` | `"horizon-sdv-https-proxy"` | no |
| <a name="input_sdv_url_map_name"></a> [sdv\_url\_map\_name](#input\_sdv\_url\_map\_name) | Define the URL map name | `string` | `"horizon-sdv-map"` | no |
| <a name="input_sdv_wi_service_accounts"></a> [sdv\_wi\_service\_accounts](#input\_sdv\_wi\_service\_accounts) | A map of service accounts and their configurations for WI | <pre>map(object({<br/>    account_id   = string<br/>    display_name = string<br/>    description  = string<br/>    gke_sas = list(object({<br/>      gke_ns = string<br/>      gke_sa = string<br/>    }))<br/>    roles = set(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_sdv_zone"></a> [sdv\_zone](#input\_sdv\_zone) | Define the default region zone for the project | `string` | n/a | yes |

## Outputs

No outputs.
