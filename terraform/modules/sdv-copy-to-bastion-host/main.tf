
data "google_project" "project" {}

# Read the content of the local text file into a local variable
locals {
  file_content = file("${var.local_file_path}")
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
      # Create all the directories defined by the filename
      mkdir -p ${var.destination_directory}

      gsutil cp gs://${var.bucket_name}/${var.bucket_destination_path} ${var.destination_directory}/${var.destination_filename}
    "
    EOT
  }

  depends_on = [google_storage_bucket_object.copy_file_to_storage]
}
