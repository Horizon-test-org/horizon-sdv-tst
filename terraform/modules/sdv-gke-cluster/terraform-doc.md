## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_container_cluster.sdv_cluster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_container_node_pool.sdv_build_node_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [google_container_node_pool.sdv_main_node_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_build_node_pool_machine_type"></a> [build\_node\_pool\_machine\_type](#input\_build\_node\_pool\_machine\_type) | Type fo the machine for the build node pool | `string` | n/a | yes |
| <a name="input_build_node_pool_max_node_count"></a> [build\_node\_pool\_max\_node\_count](#input\_build\_node\_pool\_max\_node\_count) | Number of max of nodes for the build node pool | `number` | `3` | no |
| <a name="input_build_node_pool_min_node_count"></a> [build\_node\_pool\_min\_node\_count](#input\_build\_node\_pool\_min\_node\_count) | Number of minimum of nodes for the build node pool | `number` | `0` | no |
| <a name="input_build_node_pool_name"></a> [build\_node\_pool\_name](#input\_build\_node\_pool\_name) | Name of the build node pool | `string` | n/a | yes |
| <a name="input_build_node_pool_node_count"></a> [build\_node\_pool\_node\_count](#input\_build\_node\_pool\_node\_count) | Number of nodes for the build node pool | `number` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Define the default location for the project | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Define the machine type of the node poll | `string` | `"e2-medium"` | no |
| <a name="input_network"></a> [network](#input\_network) | Name of the network | `string` | n/a | yes |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Define the number of node count | `number` | `1` | no |
| <a name="input_node_locations"></a> [node\_locations](#input\_node\_locations) | Define the location of the nodes | `list(string)` | <pre>[<br/>  "europe-west1-d"<br/>]</pre> | no |
| <a name="input_node_pool_name"></a> [node\_pool\_name](#input\_node\_pool\_name) | Name of the cluster node pool | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Define the project id | `string` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Define the service account of the node poll | `string` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | Name of the subnetwork | `string` | n/a | yes |

## Outputs

No outputs.
