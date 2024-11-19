## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.execute_bash_commands](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_host"></a> [bastion\_host](#input\_bastion\_host) | Define of the bastion host | `string` | n/a | yes |
| <a name="input_command"></a> [command](#input\_command) | Define the commands to run | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | Define the region zone | `string` | n/a | yes |

## Outputs

No outputs.
