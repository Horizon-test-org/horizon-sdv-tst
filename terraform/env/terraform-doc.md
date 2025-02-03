## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.6 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_base"></a> [base](#module\_base) | ../../modules/base | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sdv_gh_app_id"></a> [sdv\_gh\_app\_id](#input\_sdv\_gh\_app\_id) | The var gh\_app\_id value | `string` | n/a | yes |
| <a name="input_sdv_gh_app_key"></a> [sdv\_gh\_app\_key](#input\_sdv\_gh\_app\_key) | The secret GH\_APP\_KEY value | `string` | n/a | yes |
| <a name="input_sdv_gh_app_key_pkcs8"></a> [sdv\_gh\_app\_key\_pkcs8](#input\_sdv\_gh\_app\_key\_pkcs8) | The secret GH\_APP\_KEY converted to pkcs8 value | `string` | n/a | yes |
| <a name="input_sdv_gh_argocd_initial_password"></a> [sdv\_gh\_argocd\_initial\_password](#input\_sdv\_gh\_argocd\_initial\_password) | The secret ARGOCD\_INITIAL\_PASSWORD value | `string` | n/a | yes |
| <a name="input_sdv_gh_installation_id"></a> [sdv\_gh\_installation\_id](#input\_sdv\_gh\_installation\_id) | The var gh\_installation\_id value | `string` | n/a | yes |
| <a name="input_sdv_gh_jenkins_initial_password"></a> [sdv\_gh\_jenkins\_initial\_password](#input\_sdv\_gh\_jenkins\_initial\_password) | The secret JENKINS\_INITIAL\_PASSWORD value | `string` | n/a | yes |
| <a name="input_sdv_gh_keycloak_initial_password"></a> [sdv\_gh\_keycloak\_initial\_password](#input\_sdv\_gh\_keycloak\_initial\_password) | The secret KEYCLOAK\_INITIAL\_PASSWORD value | `string` | n/a | yes |
| <a name="input_sdv_gh_mtkc_regcred"></a> [sdv\_gh\_mtkc\_regcred](#input\_sdv\_gh\_mtkc\_regcred) | The secret Github MTKC-REGRED value | `string` | n/a | yes |

## Outputs

No outputs.
