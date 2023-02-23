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

locals {
  private_network = var.use_vpc ? google_compute_network.private[0] : null
}

resource "google_sql_database_instance" "main" {
  deletion_protection = false

  name             = var.database_instance_name
  database_version = "MYSQL_8_0"
  project          = var.database_project_id != null ? var.database_project_id : var.project_id
  region           = var.database_region != null ? var.database_region : var.region

  settings {
    tier              = var.database_tier
    availability_type = var.database_availability_type

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = false
      record_client_address   = false
    }

    dynamic "ip_configuration" {
      # Includes this block only if `local.private_network` is set to a non-null value.
      for_each = local.private_network[*]
      content {
        ipv4_enabled = false
        private_network = local.private_network.id
      }
    }

    maintenance_window {
      day  = 7
      hour = 2
    }
  }

  depends_on = [
    google_project_service.apis,
    google_service_networking_connection.private_vpc_connection,
  ]
}

resource "google_sql_database" "crmint" {
  name     = var.database_name
  instance = google_sql_database_instance.main.name
}

resource "random_password" "main_db_password" {
  length  = 16
  special = false
}

resource "google_sql_user" "crmint" {
  name     = var.database_user
  instance = google_sql_database_instance.main.name
  password = random_password.main_db_password.result
}
