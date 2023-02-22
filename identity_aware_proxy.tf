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

resource "google_project_service" "iap_service" {
  project = var.project_id
  service = "iap.googleapis.com"
}

resource "google_iap_brand" "default" {
  count             = var.iap_brand_id == null ? 1 : 0
  support_email     = var.iap_support_email
  application_title = "Cloud IAP protected Application"
  project           = google_project_service.iap_service.project
}

resource "google_iap_client" "default" {
  display_name = "Test Client"
  brand        =  var.iap_brand_id == null ? google_iap_brand.default[0].name : "projects/${var.project_id}/brands/${var.iap_brand_id}"
}

resource "google_project_service_identity" "iap_sa" {
  provider = google-beta
  project  = google_project_service.iap_service.project
  service  = "iap.googleapis.com"
}

resource "google_project_iam_member" "iap_sa--run_invoker" {
  project = google_project_service.iap_service.project
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_project_service_identity.iap_sa.email}"
}
