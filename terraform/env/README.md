
# Variables

The variable defined in the dev are assigned using environment variables.

The environment variables are created using the github workflow.

The Step "set environment variables" from the terraform.yaml file creates the
environment variable that initialize the variables.

The prefix *TF_VAR_* defines that the variable will be read by terraform and
init a variable with it.

## Sample

In terraform.yaml file, the follow line defines the *TF_VAR_sdv_gh_app_id* that
is read by terraform to initialize the *sdv_gh_app_id* variable:

```bash
echo "TF_VAR_sdv_gh_app_id=${{ vars.GH_APP_ID }}" >> $GITHUB_ENV;
```


# Terraform doc

[Terraform-doc](terraform-doc.md)
