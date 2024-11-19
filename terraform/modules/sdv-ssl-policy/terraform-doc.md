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
| [google_compute_ssl_policy.gke_ssl_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_policy) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | Define the min\_tls\_version value | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | SSL Policy name | `string` | n/a | yes |
| <a name="input_profile"></a> [profile](#input\_profile) | Define profile value | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssl_policy_id"></a> [ssl\_policy\_id](#output\_ssl\_policy\_id) | The ID of the created SSL policy. |
| <a name="output_ssl_policy_self_link"></a> [ssl\_policy\_self\_link](#output\_ssl\_policy\_self\_link) | The self link of the created SSL policy. |
