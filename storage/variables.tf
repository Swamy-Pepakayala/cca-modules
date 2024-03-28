variable "names" {
  description = "Bucket name suffixes."
  type        = list(string)
}

variable "project_id" {
  description = "Bucket project id."
  type        = string
}

variable "location" {
  description = "Bucket location."
  type        = string
  default     = "EU"
}

variable "storage_class" {
  description = "Bucket storage class."
  type        = string
  default     = "MULTI_REGIONAL"
}

variable "folders" {
  description = "Map of lowercase unprefixed name => list of top level folder objects."
  type        = map
  default     = {}
}

variable "lifecycle_age" {
  description = "Set lifecycle of objects in buckets."
  type = object({
    delete_age = number
  })
  default = {
    delete_age = 30
  }
}

variable "storage_iam_members" {
  description = "IAM members for each storage."
  type        = map(map(list(string)))
  default     = {}
}

variable "storage_iam_roles" {
  description = "IAM roles for each storage."
  type        = map(list(string))
  default     = {}
}
