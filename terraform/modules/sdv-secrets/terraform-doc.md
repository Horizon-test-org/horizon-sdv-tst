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
| [google_secret_manager_secret.sdv_gsms](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_binding.sdv_secret_accessor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_binding) | resource |
| [google_secret_manager_secret_version.sdv_gsmsv_dont_use_github_value](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_secret_manager_secret_version.sdv_gsmsv_use_github_value](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gcp_secrets_map"></a> [gcp\_secrets\_map](#input\_gcp\_secrets\_map) | A map of secrets with their IDs and values. | <pre>map(object({<br/>    secret_id        = string<br/>    value            = string<br/>    use_github_value = bool<br/>    gke_access = list(object({<br/>      ns = string<br/>      sa = string<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Define the secret replication location | `string` | n/a | yes |

## Outputs

No outputs.
