## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iap_tunneling"></a> [iap\_tunneling](#module\_iap\_tunneling) | terraform-google-modules/bastion-host/google//modules/iap-tunneling | ~> 7.0 |
| <a name="module_instance_template"></a> [instance\_template](#module\_instance\_template) | terraform-google-modules/vm/google//modules/instance_template | ~> 12.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_instance_from_template.vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_from_template) | resource |
| [google_project_iam_member.container_admin_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.os_admin_login_bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.storage_object_viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.vm_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.service_account_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_host_name"></a> [host\_name](#input\_host\_name) | Define the host name | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type for the bastion host | `string` | `"n1-standard-1"` | no |
| <a name="input_members"></a> [members](#input\_members) | List of members allowed to access the bastion server | `list(string)` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Define the Network | `string` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Define the Service account | `string` | n/a | yes |
| <a name="input_source_image"></a> [source\_image](#input\_source\_image) | Define the Source image | `string` | `"projects/debian-cloud/global/images/debian-12-bookworm-v20240815"` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | Define the Sub Network | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | Define the zone | `string` | n/a | yes |

## Outputs

No outputs.
