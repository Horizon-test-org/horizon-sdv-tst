
variable "file" {
  description = "The path of the file to be copied."
  type        = string
}

variable "bastion_host" {
  description = "The name of the bastion host."
  type        = string
}

variable "destination_path" {
  description = "The destination path for the file"
  type        = string
}

variable "zone" {
  description = "Define the region zone"
  type        = string
}

variable "location" {
  description = "Define the loation of the storage"
  type        = string
}

variable "bucket_name" {
  description = "Name of the bucket"
}

variable "bucket_destination_path" {
  description = "Define the path of the file inside the defined bucket"
  type        = string
}
