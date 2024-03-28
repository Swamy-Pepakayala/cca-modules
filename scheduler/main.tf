resource "google_cloud_scheduler_job" "job" {
  count 	   = length(var.names)
  name             = var.names[count.index]
  description      = "Trigger the Cloud Function every x mins."
  schedule         = var.schedule
  time_zone        = "Europe/Dublin"
  attempt_deadline = "320s"

  http_target {
    http_method = "GET"
    uri         = var.https_trigger_url[count.index]

    oidc_token {
      service_account_email = var.sa_email
    }
  }
}
