
variable "sdv_gh_app_id" {
  description = "The var gh_app_id value"
  type        = string
}

variable "sdv_gh_installation_id" {
  description = "The var gh_installation_id value"
  type        = string
}

variable "sdv_gh_app_key" {
  description = "The secret GH_APP_KEY value"
  type        = string
}

variable "sdv_gh_app_key_pkcs8" {
  description = "The secret GH_APP_KEY converted to pkcs8 value"
  type        = string
}

variable "sdv_gh_argocd_initial_password" {
  description = "The secret ARGOCD_INITIAL_PASSWORD value"
  type        = string
}

variable "sdv_gh_jenkins_initial_password" {
  description = "The secret JENKINS_INITIAL_PASSWORD value"
  type        = string
}

variable "sdv_gh_keycloak_initial_password" {
  description = "The secret KEYCLOAK_INITIAL_PASSWORD value"
  type        = string
}

variable "sdv_gh_mtkc_regcred" {
  description = "The secret Github MTKC-REGRED value"
  type        = string
}
