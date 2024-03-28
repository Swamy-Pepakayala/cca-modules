variable "service" {
    description = "Cloud run service name"
    type = string 
}

variable "project_id" {
   description = "The name of the GCP project."
   type        = string
 }

variable "location" {
  description = "Location for Cloud Run Service"
  type = string
}

variable "port" {
  description = "Container Port"
  type = number
}

variable "image"{
  description = "Container image"
  type = string
}

variable "service_account_email" {}

