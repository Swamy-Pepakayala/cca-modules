data "google_cloud_run_service" "run-service" {
  name = var.cloudrun
  location = "europe-west4"
}

//Serverless NEGs allow you to use Google Cloud serverless apps with external HTTP(S) Load Balancing.

resource "google_compute_region_network_endpoint_group" "neg" {
  name                  = var.appname
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = data.google_cloud_run_service.run-service.name
  }
  # uncomment if you need to change this and you run into problems
   lifecycle {
     create_before_destroy = true
   }
}

/*resource "google_iap_client" "project_client" {
  display_name = "IAP CLIENT FOR CODC Terraform"
  brand        =  "projects/406888444822/brands/406888444822"
}*/

/*A backend service defines how Cloud Load Balancing distributes traffic. The backend service configuration contains a set of values, 
such as the protocol used to connect to backends, various distribution and session settings, health checks, and timeouts. 
These settings provide fine-grained control over how your load balancer behaves.*/

resource "google_compute_backend_service" "backendserv" {
  name                  = "${var.appname}-backend"
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL"
  backend {
    group = google_compute_region_network_endpoint_group.neg.id
  }
  /*iap {
    oauth2_client_id = google_iap_client.project_client.client_id
    oauth2_client_secret = google_iap_client.project_client.secret
  }*/
}


//  A URL map is a set of rules for routing incoming HTTP(S) requests to specific backend services or backend buckets

resource "google_compute_url_map" "urlmap" {
  name        = "${var.appname}-https-url-map"
  description = "URL mapping for the ${var.appname} HTTPS proxy"

  default_service = google_compute_backend_service.backendserv.id
}

/*Reserving an IP address is also essential if you use a custom domain for your serverless app (also required for Google-managed SSL certificates). 
You will need to update your DNS records to point your domain to this IP address with a custom domain.*/

resource "google_compute_global_address" "staticip" {
  name = "${var.appname}-address"
}

data "google_dns_managed_zone" "env_dns_zone" {
  name = "codc"
}

locals {
  dns_name="dev.codc.selling.ingka.com."
}

resource "google_dns_record_set" "app_domain" {
  name         =  local.dns_name
  type         = "A"
  ttl          = 3600
  managed_zone = data.google_dns_managed_zone.env_dns_zone.name
  rrdatas      = [google_compute_global_address.staticip.address]
}

// Create a Google-managed SSL certificate resource

resource "google_compute_managed_ssl_certificate" "default" {
  name = "${var.appname}-cert"

  managed {
    domains = [local.dns_name]
  }
}

// Create the target HTTPS proxy to route requests to your URL map


resource "google_compute_target_https_proxy" "default" {
  name             = "${var.appname}-https-proxy"
  url_map          = google_compute_url_map.urlmap.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

// Create a forwarding rule to route incoming requests to the proxy


resource "google_compute_global_forwarding_rule" "default" {
  name       = "${var.appname}-forwarding-rule-https"
  load_balancing_scheme = "EXTERNAL"
  target     = google_compute_target_https_proxy.default.id
  port_range = 443
  ip_address = google_compute_global_address.staticip.id
}



