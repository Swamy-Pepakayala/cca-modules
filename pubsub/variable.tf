variable "project_id" {
  description = "The ID of the project where this VPC will be created"
}

variable "topic_name" {
  description = "PubSub topic name"
}

variable "dead_letter_configs" {
  description = "Per-subscription dead letter policy configuration."
  type = map(object({
    topic                = string
    max_delivery_attempts = number
  }))
  default = {}
}

variable "defaults" {
  description = "Subscription defaults for options."
  type = object({
    ack_deadline_seconds       = number
    message_retention_duration = number
    retain_acked_messages      = bool
    expiration_policy_ttl      = string
    filter		       = string	
  })
  default = {
    ack_deadline_seconds       = null
    message_retention_duration = null
    retain_acked_messages      = null
    expiration_policy_ttl      = null
    filter		       = null
  }
}

variable "iam_members" {
  description = "IAM members for each topic role."
  type        = map(list(string))
  default     = {}
}

variable "labels" {
  description = "Labels."
  type        = map(string)
  default     = {managed_by = "terraform"}
}

variable "cldstorage_configs" {
  description = "Cld Storage configurations."
  type = map(object({
    bucket_name = string
  }))
  default = {}
}

variable "push_configs" {
  description = "Push subscription configurations."
  type = map(object({
    attributes = map(string)
    endpoint   = string
    oidc_token = object({
      audience              = string
      service_account_email = string
    })
  }))
  default = {}
}

variable "retry_policy" {
  description = "retry_policy"
  type = map(object({
    maximum_backoff = string
    minimum_backoff   = string
  }))
  default = {}
}

variable "subscriptions" {
  description = "Topic subscriptions. Also define push configs for push subscriptions. If options is set to null subscription defaults will be used. Labels default to topic labels if set to null."
  type = map(object({
    labels = map(string)
    options = object({
      ack_deadline_seconds       = number
      message_retention_duration = string
      retain_acked_messages      = bool
      expiration_policy_ttl      = string
    })
  }))
  default = {}
}

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

variable "sub_names" {
    description = "Name of Subscription1"
    type = list(string)
    default = ["cca-pubsub-subscription1","cca-pubsub-subscription2"]
}

