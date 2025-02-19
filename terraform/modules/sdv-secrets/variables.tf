
variable "project_id" {
  description = "Define the project id"
  type        = string
}

variable "location" {
  description = "Define the secret replication location"
  type        = string
}

#
# Define Secrets map id and value
variable "gcp_secrets_map" {
  description = "A map of secrets with their IDs and values."
  type = map(object({
    secret_id        = string
    value            = string
    use_github_value = bool
    gke_access = list(object({
      ns = string
      sa = string
    }))
  }))
}

