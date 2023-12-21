/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_compute_global_address" "default" {
  name         = var.random_suffix ? "global-crmint-default-${random_id.suffix.hex}" : "global-crmint-default"
  description  = "Managed by ${local.managed_by_desc}"
  address_type = "EXTERNAL"

  # Create a network only if the compute.googleapis.com API has been activated.
  depends_on = [google_project_service.apis]
}

resource "google_compute_region_network_endpoint_group" "frontend_neg" {
  name                  = var.random_suffix ? "frontend-neg-${random_id.suffix.hex}" : "frontend-neg"
  description           = "Managed by ${local.managed_by_desc}"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_service.frontend_run.name
  }
}

resource "google_compute_region_network_endpoint_group" "controller_neg" {
  name                  = var.random_suffix ? "controller-neg-${random_id.suffix.hex}" : "controller-neg"
  description           = "Managed by ${local.managed_by_desc}"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_service.controller_run.name
  }
}

resource "google_compute_region_network_endpoint_group" "jobs_neg" {
  name                  = var.random_suffix ? "jobs-neg-${random_id.suffix.hex}" : "jobs-neg"
  description           = "Managed by ${local.managed_by_desc}"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_service.jobs_run.name
  }
}

resource "google_compute_backend_service" "frontend_backend" {
  name        = var.random_suffix ? "crmint-frontend-backend-service-${random_id.suffix.hex}" : "crmint-frontend-backend-service"
  description = "Managed by ${local.managed_by_desc}"

  enable_cdn                      = false
  connection_draining_timeout_sec = 10

  backend {
    group = google_compute_region_network_endpoint_group.frontend_neg.id
  }

  iap {
    oauth2_client_id     = google_iap_client.default.client_id
    oauth2_client_secret = google_iap_client.default.secret
  }

  load_balancing_scheme = "EXTERNAL"
  protocol              = "HTTP"
}

resource "google_compute_backend_service" "controller_backend" {
  name        = var.random_suffix ? "crmint-controller-backend-service-${random_id.suffix.hex}" : "crmint-controller-backend-service"
  description = "Managed by ${local.managed_by_desc}"

  enable_cdn                      = false
  connection_draining_timeout_sec = 10

  backend {
    group = google_compute_region_network_endpoint_group.controller_neg.id
  }

  iap {
    oauth2_client_id     = google_iap_client.default.client_id
    oauth2_client_secret = google_iap_client.default.secret
  }

  load_balancing_scheme = "EXTERNAL"
  protocol              = "HTTP"
}

resource "google_compute_backend_service" "jobs_backend" {
  name        = var.random_suffix ? "crmint-jobs-backend-service-${random_id.suffix.hex}" : "crmint-jobs-backend-service"
  description = "Managed by ${local.managed_by_desc}"

  enable_cdn                      = false
  connection_draining_timeout_sec = 10

  backend {
    group = google_compute_region_network_endpoint_group.jobs_neg.id
  }

  iap {
    oauth2_client_id     = google_iap_client.default.client_id
    oauth2_client_secret = google_iap_client.default.secret
  }

  load_balancing_scheme = "EXTERNAL"
  protocol              = "HTTP"
}

resource "google_compute_url_map" "default" {
  name        = var.random_suffix ? "crmint-http-lb-${random_id.suffix.hex}" : "crmint-http-lb"
  description = "Managed by ${local.managed_by_desc}"

  default_service = google_compute_backend_service.frontend_backend.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.frontend_backend.id

    path_rule {
      service = google_compute_backend_service.jobs_backend.id
      paths   = ["/api/workers", "/api/workers/*", "/push/start-task"]
    }

    path_rule {
      service = google_compute_backend_service.controller_backend.id
      paths   = ["/api/*", "/push/task-finished", "/push/start-pipeline"]
    }
  }
}

resource "google_compute_target_https_proxy" "default" {
  name        = var.random_suffix ? "crmint-default-https-lb-proxy-${random_id.suffix.hex}" : "crmint-default-https-lb-proxy"
  description = "Managed by ${local.managed_by_desc}"

  url_map = google_compute_url_map.default.id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.default.id,
  ]
}

resource "google_compute_global_forwarding_rule" "default" {
  name        = var.random_suffix ? "crmint-default-https-lb-forwarding-rule-${random_id.suffix.hex}" : "crmint-default-https-lb-forwarding-rule"
  description = "Managed by ${local.managed_by_desc}"

  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443"
  target                = google_compute_target_https_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}

##
# Virtual Private Cloud

resource "google_compute_network" "private" {
  provider = google-beta
  count    = var.use_vpc ? 1 : 0

  name        = var.random_suffix ? "crmint-private-network-${random_id.suffix.hex}" : "crmint-private-network"
  description = "Managed by ${local.managed_by_desc}"

  project                 = var.network_project_id != null ? var.network_project_id : var.project_id
  routing_mode            = "REGIONAL"
  mtu                     = 1460
  auto_create_subnetworks = false # Custom Subnet Mode

  # Create a network only if the compute.googleapis.com API has been activated.
  depends_on = [google_project_service.apis]
}

resource "google_compute_global_address" "db_private_ip_address" {
  provider = google-beta
  count    = var.use_vpc ? 1 : 0

  name        = var.random_suffix ? "crmint-db-private-ip-address-${random_id.suffix.hex}" : "crmint-db-private-ip-address"
  description = "Managed by ${local.managed_by_desc}"

  project       = var.network_project_id != null ? var.network_project_id : var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = "192.168.0.0"
  prefix_length = 16
  network       = google_compute_network.private[count.index].id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta
  count    = var.use_vpc ? 1 : 0

  network                 = google_compute_network.private[count.index].id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.db_private_ip_address[count.index].name]
}

resource "google_compute_subnetwork" "private" {
  count = var.use_vpc ? 1 : 0

  name        = var.random_suffix ? "crmint-private-subnetwork-${random_id.suffix.hex}" : "crmint-private-subnetwork"
  description = "Managed by ${local.managed_by_desc}"

  ip_cidr_range = "10.8.0.0/28"
  region        = var.network_region != null ? var.network_region : var.region
  network       = google_compute_network.private[count.index].id
}

resource "google_vpc_access_connector" "connector" {
  provider = google-beta
  count    = var.use_vpc ? 1 : 0

  name = var.random_suffix ? "crmint-vpc-conn-${random_id.suffix.hex}" : "crmint-vpc-conn"

  machine_type  = "e2-micro"
  max_instances = 3
  min_instances = 2
  project       = var.network_project_id != null ? var.network_project_id : var.project_id
  region        = var.network_region != null ? var.network_region : var.region

  subnet {
    name       = google_compute_subnetwork.private[count.index].name
    project_id = var.network_project_id != null ? var.network_project_id : var.project_id
  }

  depends_on = [google_project_service.vpcaccess]
}
