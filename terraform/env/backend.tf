terraform {
  required_version = ">= 1.9.6"
  backend "gcs" {
    bucket = "prj-tst-horizon-sdv-tf"
    prefix = "prj-tst-horizon-sdv-tf-state"
  }
}
