resource "google_cloudfunctions_function" "appcloudfunction" {
  count	      = length(var.name)
  name        = var.name[count.index]
  runtime     = var.runtime
#  source      = var.source_code_path
  entry_point = "main"
  trigger_http = true
  available_memory_mb = 256
#  timeout_sec = 60
}
