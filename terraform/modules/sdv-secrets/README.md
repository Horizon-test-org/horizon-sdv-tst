
# SDV Secrets

This module creates several secrets and give the access to the defined Kubernetes
SAs.

## How does it works

+ Create a Secret on github for the environment
+ Update the github actions to create an environment variable from the secret
+ Create a terraform variable in the environment tha will receive the environment variable value
+ Create an entry in the sdv_gcp_secrets_map variable to map the variable to the gcp secret


## Define the terraform to create the secret

Example how to define the secret creation:

```terraform
  sdv_gcp_secrets_map = {
    s1 = {
      secret_id        = "githubAppID"
      value            = var.sdv_gh_app_id
      use_github_value = true
      gke_access = [
        {
          ns = "argocd"
          sa = "argocd-sa"
        },
        {
          ns = "jenkins"
          sa = "jenkins-sa"
        }
      ]
    }
```

+ s1 - Unique identifier in the map
+ secret_id - Name of the secret on the GC Project
+ value - Value for the secret
+ use_github_value - will update the secret on GC if the value is updated on GitHub
+ gke_access - define the Namespace **ns** and Service Account **sa** that can access this secret from the Kubernetes instance.


# Terraform doc

[Terraform-doc](terraform-doc.md)

