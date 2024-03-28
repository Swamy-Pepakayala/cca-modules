# Create a service account and grant necessary permissions
resource "google_service_account" "service_account" {
  project      = var.project_id
  account_id   = var.name
  display_name = var.display_name
}


output "sa_email" {
 description  = "service account email"
 value = google_service_account.service_account.email
}
