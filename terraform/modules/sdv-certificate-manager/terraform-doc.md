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
| [google_certificate_manager_certificate.horizon_sdv_cert](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate) | resource |
| [google_certificate_manager_certificate_map.horizon_sdv_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate_map) | resource |
| [google_certificate_manager_certificate_map_entry.horizon_sdv_map_entry](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate_map_entry) | resource |
| [google_certificate_manager_dns_authorization.instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_dns_authorization) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | Define the domain of the certificate | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `"Define the name of the certificate"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_record_data_to_insert"></a> [record\_data\_to\_insert](#output\_record\_data\_to\_insert) | n/a |
| <a name="output_record_name_to_insert"></a> [record\_name\_to\_insert](#output\_record\_name\_to\_insert) | n/a |
| <a name="output_record_type_to_insert"></a> [record\_type\_to\_insert](#output\_record\_type\_to\_insert) | n/a |
