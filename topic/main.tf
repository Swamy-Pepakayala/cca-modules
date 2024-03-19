resource "google_pubsub_topic" "topic" {
  count		= length(var.name)
  project      = var.project_id
  name         = var.name[count.index]
}


output "id" {
  description = "Topic id."
  value       = google_pubsub_topic.topic[*].id
}

