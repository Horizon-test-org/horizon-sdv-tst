terraform {
  required_version = ">= 1.9.6"
  backend "gcs" {
    bucket = "prj-dev-horizon-sdv-tf"
    prefix = "prj-dev-horizon-sdv-tf-state"
  }
}
