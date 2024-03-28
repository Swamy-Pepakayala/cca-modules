locals {
  folder_list = flatten([
    for bucket, folders in var.folders : [
      for folder in folders : {
        bucket = bucket,
        folder = folder
      }
    ]
  ])
  iam_pairs = var.storage_iam_roles == null ? [] : flatten([
    for name, roles in var.storage_iam_roles :
    [for role in roles : { name = name, role = role }]
  ])
  iam_keypairs = {
    for pair in local.iam_pairs :
    "${pair.name}-${pair.role}" => pair
  }
  iam_members = (
    var.storage_iam_members == null ? {} : var.storage_iam_members
  )
}

resource "google_storage_bucket" "buckets" {
  for_each      = toset(var.names)
  name          = "${lower(each.value)}"
  project       = var.project_id
  location      = var.location
  storage_class = var.storage_class
  force_destroy = "true"

  dynamic lifecycle_rule {
    for_each = var.lifecycle_age.delete_age == null ? [] : [""]
    content {
      action { type = "Delete" }
      condition { age = var.lifecycle_age.delete_age }
    }
  }
}

resource "google_storage_bucket_object" "folders" {
  for_each   = { for obj in local.folder_list : "${obj.bucket}_${obj.folder}" => obj }
  bucket     = "${each.value.bucket}"
  name       = "${each.value.folder}/" # Declaring an object with a trailing '/' creates a directory
  content    = "default"               # Note that the content string isn't actually used, but is only there since the resource requires it
  depends_on = [google_storage_bucket.buckets]
}

resource "google_storage_bucket_iam_binding" "bindings" {
  for_each = local.iam_keypairs
  bucket   = google_storage_bucket.buckets[each.value.name].name
  role     = each.value.role
  members = lookup(
    lookup(local.iam_members, each.value.name, {}), each.value.role, []
  )
}

output "buckets" {
  description 	= "bucket resources"
  value 	= google_storage_bucket.buckets
}
