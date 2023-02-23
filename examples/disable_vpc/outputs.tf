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
  value       = module.crmint.secured_url
  description = "The url to access CRMint UI (with Google Managed certificate)."
}

output "project_id" {
  value       = module.crmint.project_id
  description = "GCP Project ID"
}

output "region" {
  value       = module.crmint.region
  description = "Region used to deploy CRMint."
}

output "report_usage_id" {
  value       = module.crmint.report_usage_id
  description = "Report Usage ID (empty if opt-out)"
}
