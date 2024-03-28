variable "project_id" {
  description = "Project used for resources."
  type        = string
}

variable "names" {
  description = "sch name."
  type        = list(string)
}

variable "schedule" {
  description = "schedule"
  type	= string
}

variable "https_trigger_url" {
  description = "https trigger"
  type	= list(string)
}

variable "sa_email" {
  description = "svc account email"
  type	= string
}

