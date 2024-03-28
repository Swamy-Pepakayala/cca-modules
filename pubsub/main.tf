locals {
  iam_pairs = var.subscription_iam_roles == null ? [] : flatten([
    for name, roles in var.subscription_iam_roles :
    [for role in roles : { name = name, role = role }]
  ])
  iam_keypairs = {
    for pair in local.iam_pairs :
    "${pair.name}-${pair.role}" => pair
  }
  iam_members = (
    var.subscription_iam_members == null ? {} : var.subscription_iam_members
  )
  oidc_config = {
    for k, v in var.push_configs : k => v.oidc_token
  }
  subscriptions = {
    for k, v in var.subscriptions : k => {
      labels  = try(v.labels, v, null) == null ? var.labels : merge(v.labels,var.labels)
      options = try(v.options, v, null) == null ? var.defaults : v.options
    }
  }
}

resource "google_pubsub_subscription" "subscription" {
  for_each                   = local.subscriptions
  project                    = var.project_id
  name                       = each.key
  topic                      = var.topic_name
  labels                     = each.value.labels
  ack_deadline_seconds       = each.value.options.ack_deadline_seconds
  message_retention_duration = each.value.options.message_retention_duration
  retain_acked_messages      = each.value.options.retain_acked_messages
  filter	 	     = each.value.options.filter
 
 dynamic expiration_policy {
    for_each = each.value.options.expiration_policy_ttl == null ? [] : [""]
    content {
      ttl = each.value.options.expiration_policy_ttl
    }
  }

  dynamic dead_letter_policy {
    for_each = try(var.dead_letter_configs[each.key], null) == null ? [] : [""]
    content {
      dead_letter_topic     = var.dead_letter_configs[each.key].topic
      max_delivery_attempts = var.dead_letter_configs[each.key].max_delivery_attempts
    }
  }

  dynamic push_config {
    for_each = try(var.push_configs[each.key], null) == null ? [] : [""]
    content {
      push_endpoint = var.push_configs[each.key].endpoint
      attributes    = var.push_configs[each.key].attributes
      dynamic oidc_token {
        for_each = (
          local.oidc_config[each.key] == null ? [] : [""]
        )
        content {
          service_account_email = local.oidc_config[each.key].service_account_email
          audience              = local.oidc_config[each.key].audience
        }
      }
    }
  }

  dynamic cloud_storage_config {
    for_each = try(var.cldstorage_configs[each.key], null) == null ? [] : [""]
    content {
        bucket = var.cldstorage_configs[each.key].bucket_name
       } 
  }
}

resource "google_pubsub_subscription_iam_binding" "subscription" {
  for_each     = local.iam_keypairs
  project      = var.project_id
  subscription = google_pubsub_subscription.subscription[each.value.name].name
  role         = each.value.role
  members = lookup(
    lookup(local.iam_members, each.value.name, {}), each.value.role, []
  )
}


/*
resource "google_pubsub_subscription" "pubsub_subscription" {
  count = length(var.sub_names)
  name  = var.sub_names[count.index]
  topic = google_pubsub_topic.apptopic.id
  #  push_config {
  #    push_endpoint = var.push_endpoint
  #  }
  message_retention_duration = "1200s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "300000.5s"
  }
  retry_policy {
    minimum_backoff = "10s"
  }

  enable_message_ordering    = false
}
*/

# Output the Pub/Sub subscription name for IAM binding
output "subscription_name" {
  value = google_pubsub_subscription.subscription
  depends_on = [
    google_pubsub_subscription_iam_binding.subscription
  ]
}

output "sub_binding" {
  value = google_pubsub_subscription_iam_binding.subscription
  depends_on = [
    google_pubsub_subscription_iam_binding.subscription
  ]
}
