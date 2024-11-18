
data "google_project" "project" {}

# Read the content of the local text file into a local variable
locals {
  file_content = file("${var.file}")
}

resource "terraform_data" "debug_file_content" {
  input = local.file_content
}

# Example usage in a Google Cloud resource (e.g., a Storage Bucket object)
resource "google_storage_bucket_object" "copy_file_to_storage" {
  name    = var.bucket_destination_path
  bucket  = var.bucket_name
  content = local.file_content
}

resource "null_resource" "copy_from_storage_to_bastion_host" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
      gcloud beta compute ssh ${var.bastion_host} --zone=${var.zone} --project=${data.google_project.project.project_id} --command="
      # Extract the directory path from the filename
      dir_path=$(dirname ${var.destination_path})
      # Create all the directories defined by the filename
      mkdir -p "$dir_path"

      gsutil cp gs://${var.bucket_name}/${var.destination_path} .
    "
    EOT
  }

  depends_on = [google_storage_bucket_object.copy_file_to_storage]
}
