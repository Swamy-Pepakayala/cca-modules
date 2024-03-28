
locals {
  iam_pairs = var.cldfunc_iam_roles == null ? [] : flatten([
    for name, roles in var.cldfunc_iam_roles :
    [for role in roles : { name = name, role = role }]
  ])
  iam_keypairs = {
    for pair in local.iam_pairs :
    "${pair.name}-${pair.role}" => pair
  }
  iam_members = (
    var.cldfunc_iam_members == null ? {} : var.cldfunc_iam_members
  )
}

resource "google_cloudfunctions2_function" "this" {
#  count = length(var.names)
  for_each     = toset(var.names)
  #name = var.names[count.index]
  name         = "${lower(each.value)}"
  location    = var.location
  description = var.description
  project     = var.project_id

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point

    source {
      storage_source {
        bucket = var.bucket_name
        #object = google_storage_bucket_object.this[count.index].name
        object = google_storage_bucket_object.this[0].name
      }
    }
  }

  service_config {
    min_instance_count             = var.min_instance_count
    max_instance_count             = var.max_instance_count
    timeout_seconds                = var.timeout_seconds
    ingress_settings               = var.ingress_settings
    all_traffic_on_latest_revision = var.all_traffic_on_latest_revision
  }

  dynamic "event_trigger" {
    for_each = (var.event_trigger == true ? ["yes"] : [])
    content {
      trigger_region        = var.location
      service_account_email = var.sa_email
      event_type            = "google.cloud.pubsub.topic.v1.messagePublished"
      pubsub_topic          = var.pubsub_topic
      retry_policy          = "RETRY_POLICY_RETRY"
    }
  }
}

data "archive_file" "this" {
  count       = length(var.names)
  type        = "zip"
  output_path = "/tmp/${var.names[count.index]}.zip"
  source_dir  = "${path.module}/../src/${var.srccde}"
  excludes    = var.excludes
}

resource "google_storage_bucket_object" "this" {
  count = length(var.names)
  name  = "${var.names[count.index]}.${data.archive_file.this[count.index].output_sha}.zip"
  #bucket = google_storage_bucket.this.id
  bucket = var.bucket_name
  source = data.archive_file.this[count.index].output_path
}

resource "google_project_iam_member" "invoking" {
  project    = var.project_id
  role       = "roles/run.invoker"
  member     = "serviceAccount:${var.sa_email}"
}

/*
resource "google_cloudfunctions2_function_iam_member" "member" {
  count          = length(var.names)
  cloud_function = google_cloudfunctions2_function.this[count.index].name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${var.sa_email}"
}
*/

resource "google_cloudfunctions2_function_iam_binding" "bindings" {
  for_each 		= local.iam_keypairs
  project  		= var.project_id
  cloud_function 	= google_cloudfunctions2_function.this[each.value.name].name  
  role     		= each.value.role
  members = lookup(
    lookup(local.iam_members, each.value.name, {}), each.value.role, []
  )
}
/*
output "id" {
  description = "An identifier for the resource with format `projects/{{project}}/locations/{{location}}/functions/{{name}}`"
  value       = google_cloudfunctions2_function.this[*].id
}

output "environment" {
  description = "The environment the function is hosted on"
  value       = google_cloudfunctions2_function.this[*].environment
}

output "state" {
  description = "Describes the current state of the function"
  value       = google_cloudfunctions2_function.this[*].state
}

output "update_time" {
  description = "The last update timestamp of a Cloud Function"
  value       = google_cloudfunctions2_function.this[*].update_time
}

output "url" {
  description = "The uri to reach the function"
  value       = google_cloudfunctions2_function.this[*].url
}

#output "uri" {
#  description = "The uri to reach the function"
#  value       = google_cloudfunctions2_function.this[*].service_config[0].uri
#}
*/
