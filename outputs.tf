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

output "secured_url" {
  value       = "https://${local.secured_domain}"
  description = "The url to access CRMint UI (with Google Managed certificate)."
}

output "project_id" {
  value       = var.project_id
  description = "GCP Project ID"
}

output "region" {
  value       = var.region
  description = "Region used to deploy CRMint."
}

output "migrate_image" {
  value       = local.migrate_image
  description = "Docker image (with tag) for the controller service."
}

output "migrate_sql_conn_name" {
  value       = local.migrate_sql_conn_name
  description = "Database instance connection name."
}

output "cloud_db_uri" {
  value       = local.cloud_db_uri
  description = "Database connection URI."
  sensitive   = true
}

output "cloud_build_worker_pool" {
  value       = local.pool
  description = "Cloud Build worker pool."
}

output "report_usage_id" {
  value       = local.report_usage_id
  description = "Report Usage ID (empty if opt-out)"
}
