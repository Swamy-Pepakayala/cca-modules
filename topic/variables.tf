variable "project_id" {
  description = "Project used for resources."
  type        = string
}

variable "name" {
  description = "PubSub topic name."
  type        = list(string)
}

variable "regions" {
  description = "List of regions used to set persistence policy."
  type        = list(string)
  default     = []
}

variable "iam" {
  description = "IAM bindings for topic in {ROLE => [MEMBERS]} format."
  type        = map(list(string))
  default     = {}
}

#variable "sa_email" {
#  description = "svc account email"
#  type	= string
#}

variable "subscription_iam_members" {
  description = "IAM members for each subscription and role."
  type        = map(map(list(string)))
  default     = {}
}

variable "subscription_iam_roles" {
  description = "IAM roles for each subscription."
  type        = map(list(string))
  default     = {}
}
