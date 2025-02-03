terraform {
  required_version = ">= 1.9.6"
  backend "gcs" {
    bucket = "prj-s-horizon-sdv-sbx-tf"
    prefix = "prj-s-horizon-sdv-sbx-tf-state"
  }
}
