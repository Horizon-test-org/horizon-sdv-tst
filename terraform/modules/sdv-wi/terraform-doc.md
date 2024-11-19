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
| [google_project_iam_member.sdv_wi_sa_iam_2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.sdv_wi_sa_wi_users_gke_ns_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.sdv_wi_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_wi_service_accounts"></a> [wi\_service\_accounts](#input\_wi\_service\_accounts) | A map of service accounts and their configurations | <pre>map(object({<br/>    account_id   = string<br/>    display_name = string<br/>    description  = string<br/>    gke_sas = list(object({<br/>      gke_ns = string<br/>      gke_sa = string<br/>    }))<br/>    roles        = set(string)<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
