## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-google-modules/network/google | ~> 9.1 |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.vpc_nat_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_router.vpc_nat_router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.vpc_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network"></a> [network](#input\_network) | Define the Network | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Define the Region | `string` | n/a | yes |
| <a name="input_router_name"></a> [router\_name](#input\_router\_name) | Define the router name | `string` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | Define the Sub Network | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_nat_ip_name"></a> [vpc\_nat\_ip\_name](#output\_vpc\_nat\_ip\_name) | The name of the created NAT ip address |
| <a name="output_vpc_nat_name"></a> [vpc\_nat\_name](#output\_vpc\_nat\_name) | The name of the created NAT. |
| <a name="output_vpc_nat_router_name"></a> [vpc\_nat\_router\_name](#output\_vpc\_nat\_router\_name) | The name of the created router for NAT. |
