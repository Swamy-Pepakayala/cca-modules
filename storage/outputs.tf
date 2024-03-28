/*
output "buckets" {
  description = "Bucket resources."
  value       = google_storage_bucket.buckets
}
*/
output "names_list" {
  description = "List of bucket names."
  value = {
    for name, resource in google_storage_bucket.buckets :
    name => resource.name
  }
} 

output "bindings" {
  description = "Bucket bindings."
  value       = google_storage_bucket_iam_binding.bindings
}
