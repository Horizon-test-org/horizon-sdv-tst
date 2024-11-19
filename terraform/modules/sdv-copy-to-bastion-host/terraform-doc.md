## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_storage_bucket_object.copy_file_to_storage](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [null_resource.copy_from_storage_to_bastion_host](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [terraform_data.debug_file_content](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_host"></a> [bastion\_host](#input\_bastion\_host) | The name of the bastion host. | `string` | n/a | yes |
| <a name="input_bucket_destination_path"></a> [bucket\_destination\_path](#input\_bucket\_destination\_path) | Define the path of the file inside the defined bucket | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the bucket | `any` | n/a | yes |
| <a name="input_destination_directory"></a> [destination\_directory](#input\_destination\_directory) | The destination path for the file | `string` | n/a | yes |
| <a name="input_destination_filename"></a> [destination\_filename](#input\_destination\_filename) | The destination filename for the file | `string` | n/a | yes |
| <a name="input_local_file_path"></a> [local\_file\_path](#input\_local\_file\_path) | The path of the local file to be copied. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Define the loation of the storage | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | Define the region zone | `string` | n/a | yes |

## Outputs

No outputs.
