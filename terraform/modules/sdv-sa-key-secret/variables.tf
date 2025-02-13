
variable "project_id" {
  description = "Define the project id"
  type        = string
}

variable "service_account_id" {
  description = "Define the service account ID"
  type        = string
}

variable "location" {
  description = "Define the secret replication location"
  type        = string
}

variable "secret_id" {
  description = "Name of the secret"
  type        = string
}

variable "gke_access" {
  description = "Define the GKE SAs the access of the secret"
  type = list(object({
    ns = string
    sa = string
  }))
}
