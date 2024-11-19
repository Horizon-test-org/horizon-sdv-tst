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
| [google_compute_backend_service.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_global_forwarding_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_http_health_check.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check) | resource |
| [google_compute_target_https_proxy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy) | resource |
| [google_compute_url_map.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | Define the domain of the certificate | `string` | n/a | yes |
| <a name="input_ssl_certificate_name"></a> [ssl\_certificate\_name](#input\_ssl\_certificate\_name) | Define the SSL Certificate name | `string` | n/a | yes |
| <a name="input_target_https_proxy_name"></a> [target\_https\_proxy\_name](#input\_target\_https\_proxy\_name) | Define the name of https proxy name | `string` | n/a | yes |
| <a name="input_url_map_name"></a> [url\_map\_name](#input\_url\_map\_name) | Define the name of the url map | `string` | n/a | yes |

## Outputs

No outputs.
