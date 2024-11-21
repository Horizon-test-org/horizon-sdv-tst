variable "member" {
  description = "List of users and SA for the project"
  type        = set(string)
}

variable "role" {
  description = "role assigned to members"
  type        = string

}
