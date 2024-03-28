variable "project_id" {
  type        = string
  description = "The project id to create Workload Identity Pool"
}

variable "name" {
  type        = string
  description = "service account gcp"
}

variable "display_name" {
  type = string
  description = "service account display name"
}
