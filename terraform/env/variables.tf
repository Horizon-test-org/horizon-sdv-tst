
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

variable "sdv_gh_argocd_initial_password_bcrypt" {
  description = "The secret ARGOCD_INITIAL_PASSWORD_BCRYPT value"
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

variable "sdv_gh_gerrit_admin_initial_password" {
  description = "The secret Github GERRIT_ADMIN_INITIAL_PASSWORD value"
  type        = string
}

variable "sdv_gh_gerrit_admin_private_key" {
  description = "The secret Github GERRIT_ADMIN_PRIVATE_KEY value"
  type        = string
}

variable "sdv_gh_keycloak_horizon_admin_password" {
  description = "The secret Github KEYCLOAK_HORIZON_ADMIN_PASSWORD value"
  type        = string
}

variable "sdv_gh_cuttlefish_vm_ssh_private_key" {
  description = "The secret Github CUTTLEFISH_VM_SSH_PRIVATE_KEY value"
  type        = string
}

variable "sdv_gh_access_token" {
  description = "Github access token"
  type        = string
}
