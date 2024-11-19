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
| [google_artifact_registry_repository.docker_repo](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_project_iam_member.artifact_registry_reader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.artifact_registry_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Define the location of the artifact registry | `string` | n/a | yes |
| <a name="input_members"></a> [members](#input\_members) | Define the users that have write access to the artifact registry | `list(string)` | n/a | yes |
| <a name="input_reader_members"></a> [reader\_members](#input\_reader\_members) | Define the users that have reader access to the artifact registry | `list(string)` | n/a | yes |
| <a name="input_repository_id"></a> [repository\_id](#input\_repository\_id) | Define the name of the artifact repository | `string` | n/a | yes |

## Outputs

No outputs.
