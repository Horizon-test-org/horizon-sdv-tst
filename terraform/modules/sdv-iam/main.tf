data "google_project" "project" {}

resource "google_project_iam_member" "iam_member" {
  for_each = var.member
  project  = data.google_project.project.project_id
  role     = var.role
  member   = each.value
}
