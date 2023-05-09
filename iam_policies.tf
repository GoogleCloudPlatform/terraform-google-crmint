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

resource "google_service_account" "frontend_sa" {
  account_id   = var.random_suffix ? "crmint-frontend-sa-${random_id.suffix.hex}" : "crmint-frontend-sa"
  display_name = "CRMint Frontend Service Account"
  description  = "Managed by ${local.managed_by_desc}"
  project      = var.project_id
  depends_on   = [google_project_service.apis]
}

resource "google_service_account" "jobs_sa" {
  account_id   = var.random_suffix ? "crmint-jobs-sa-${random_id.suffix.hex}" : "crmint-jobs-sa"
  display_name = "CRMint Jobs Service Account"
  description  = "Managed by ${local.managed_by_desc}"
  project      = var.project_id
  depends_on   = [google_project_service.apis]
}

resource "google_service_account" "controller_sa" {
  account_id   = var.random_suffix ? "crmint-controller-sa-${random_id.suffix.hex}" : "crmint-controller-sa"
  display_name = "CRMint Controller Service Account"
  description  = "Managed by ${local.managed_by_desc}"
  project      = var.project_id
  depends_on   = [google_project_service.apis]
}

resource "google_service_account" "pubsub_sa" {
  account_id   = var.random_suffix ? "crmint-pubsub-sa-${random_id.suffix.hex}" : "crmint-pubsub-sa"
  display_name = "CRMint PubSub Service Account"
  description  = "Managed by ${local.managed_by_desc}"
  project      = var.project_id
  depends_on   = [google_project_service.apis]
}

resource "google_project_service_identity" "iap_managed_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "iap.googleapis.com"
}

resource "google_project_service_identity" "cloudbuild_managed_sa" {
  provider   = google-beta
  project    = var.project_id
  service    = "cloudbuild.googleapis.com"
  depends_on = [google_project_service.apis]
}

resource "google_project_service_identity" "pubsub_managed_sa" {
  provider   = google-beta
  project    = var.project_id
  service    = "pubsub.googleapis.com"
  depends_on = [google_project_service.apis]
}

resource "google_project_iam_member" "controller_sa--cloudsql-client" {
  member  = "serviceAccount:${google_service_account.controller_sa.email}"
  project = var.project_id
  role    = "roles/cloudsql.client"
}

resource "google_project_iam_member" "controller_sa--pubsub-publisher" {
  member  = "serviceAccount:${google_service_account.controller_sa.email}"
  project = var.project_id
  role    = "roles/pubsub.publisher"
}

resource "google_project_iam_member" "controller_sa--logging-writer" {
  member  = "serviceAccount:${google_service_account.controller_sa.email}"
  project = var.project_id
  role    = "roles/logging.logWriter"
}

resource "google_project_iam_member" "controller_sa--logging-viewer" {
  member  = "serviceAccount:${google_service_account.controller_sa.email}"
  project = var.project_id
  role    = "roles/logging.viewer"
}

resource "google_project_iam_member" "jobs_sa--pubsub-publisher" {
  member  = "serviceAccount:${google_service_account.jobs_sa.email}"
  project = var.project_id
  role    = "roles/pubsub.publisher"
}

resource "google_project_iam_member" "jobs_sa--logging-writer" {
  member  = "serviceAccount:${google_service_account.jobs_sa.email}"
  project = var.project_id
  role    = "roles/logging.logWriter"
}

resource "google_project_iam_member" "jobs_sa--bigquery-data-editor" {
  member  = "serviceAccount:${google_service_account.jobs_sa.email}"
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
}

resource "google_project_iam_member" "jobs_sa--bigquery-job-user" {
  member  = "serviceAccount:${google_service_account.jobs_sa.email}"
  project = var.project_id
  role    = "roles/bigquery.jobUser"
}

resource "google_project_iam_member" "jobs_sa--bigquery-resource-viewer" {
  member  = "serviceAccount:${google_service_account.jobs_sa.email}"
  project = var.project_id
  role    = "roles/bigquery.resourceViewer"
}

resource "google_project_iam_member" "jobs_sa--storage-object-admin" {
  member  = "serviceAccount:${google_service_account.jobs_sa.email}"
  project = var.project_id
  role    = "roles/storage.objectAdmin"
}

resource "google_project_iam_member" "jobs_sa--aiplatform-user" {
  member  = "serviceAccount:${google_service_account.jobs_sa.email}"
  project = var.project_id
  role    = "roles/aiplatform.user"
}

# Needed to access the controller image during migrations from Cloud Build.
resource "google_project_iam_member" "cloudbuild_managed_sa--object-viewer" {
  member  = "serviceAccount:${google_project_service_identity.cloudbuild_managed_sa.email}"
  project = var.project_id
  role    = "roles/storage.objectViewer"
}

# Needed to access the database during migrations from Cloud Build.
resource "google_project_iam_member" "cloudbuild_managed_sa--cloudsql-client" {
  member  = "serviceAccount:${google_project_service_identity.cloudbuild_managed_sa.email}"
  project = var.project_id
  role    = "roles/cloudsql.client"
}

# Needed for projects created on or before April 8, 2021.
# Grant the Google-managed service account the `iam.serviceAccountTokenCreator` role.
resource "google_project_iam_member" "pubsub_token-creator" {
  member  = "serviceAccount:${google_project_service_identity.pubsub_managed_sa.email}"
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
}

##
# Cloud Run permissions
#
# NOTE: We delegate the authentication flow to IAP.
#

locals {
  iap_users = {
    for index, user in concat(["serviceAccount:${google_service_account.pubsub_sa.email}"], var.iap_allowed_users) :
    "user-${index}" => user
  }
}

resource "google_iap_web_backend_service_iam_member" "frontend" {
  for_each = local.iap_users

  project             = google_compute_backend_service.frontend_backend.project
  web_backend_service = google_compute_backend_service.frontend_backend.name
  role                = "roles/iap.httpsResourceAccessor"
  member              = each.value
}

resource "google_iap_web_backend_service_iam_member" "controller" {
  for_each = local.iap_users

  project             = google_compute_backend_service.controller_backend.project
  web_backend_service = google_compute_backend_service.controller_backend.name
  role                = "roles/iap.httpsResourceAccessor"
  member              = each.value
}

resource "google_iap_web_backend_service_iam_member" "jobs" {
  for_each = local.iap_users

  project             = google_compute_backend_service.jobs_backend.project
  web_backend_service = google_compute_backend_service.jobs_backend.name
  role                = "roles/iap.httpsResourceAccessor"
  member              = each.value
}

locals {
  run_users = {
    iap_sa    = "serviceAccount:${google_project_service_identity.iap_sa.email}"
    pubsub_sa = "serviceAccount:${google_service_account.pubsub_sa.email}"
  }
}

resource "google_cloud_run_service_iam_member" "frontend_run_invoker" {
  for_each = local.run_users

  location = google_cloud_run_service.frontend_run.location
  project  = google_cloud_run_service.frontend_run.project
  service  = google_cloud_run_service.frontend_run.name
  role     = "roles/run.invoker"
  member   = each.value
}

resource "google_cloud_run_service_iam_member" "controller_run_invoker" {
  for_each = local.run_users

  location = google_cloud_run_service.controller_run.location
  project  = google_cloud_run_service.controller_run.project
  service  = google_cloud_run_service.controller_run.name
  role     = "roles/run.invoker"
  member   = each.value
}

resource "google_cloud_run_service_iam_member" "jobs_run_invoker" {
  for_each = local.run_users

  location = google_cloud_run_service.jobs_run.location
  project  = google_cloud_run_service.jobs_run.project
  service  = google_cloud_run_service.jobs_run.name
  role     = "roles/run.invoker"
  member   = each.value
}
