resource "google_cloud_run_v2_service" "default" {
  name     = var.service
  location = var.location
  #ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  

  template {
    scaling {
      min_instance_count = 1
      max_instance_count = 5
    }
    containers {
      ports {
        container_port = var.port
      }
      image = var.image
    }
  }
   traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

resource "google_cloud_run_v2_service_iam_binding" "binding" {
  project       = var.project_id
  location 	= var.location
  name 	        = google_cloud_run_v2_service.default.name
  role          = "roles/run.invoker"
  members = [
	"serviceAccount:${var.service_account_email}"
  ]
}

output "service_name" {
  value = google_cloud_run_v2_service.default.name
}

