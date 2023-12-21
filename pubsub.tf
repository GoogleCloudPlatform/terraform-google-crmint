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
  subscriptions = {
    "crmint-3-start-task" = {
      "endpoint"             = "${google_cloud_run_service.jobs_run.status[0].url}/push/start-task",
      "ack_deadline_seconds" = 600,
      "minimum_backoff"      = 60, # seconds
    }

    "crmint-3-task-finished" = {
      "endpoint"             = "${google_cloud_run_service.controller_run.status[0].url}/push/task-finished",
      "ack_deadline_seconds" = 60,
      "minimum_backoff"      = 10, # seconds
    }

    "crmint-3-start-pipeline" = {
      "endpoint"             = "${google_cloud_run_service.controller_run.status[0].url}/push/start-pipeline",
      "ack_deadline_seconds" = 60,
      "minimum_backoff"      = 10, # seconds
    }
  }
}

resource "google_pubsub_topic" "topics" {
  for_each = local.subscriptions

  name   = var.random_suffix ? "${each.key}-${random_id.suffix.hex}" : each.key
  labels = var.labels

  depends_on = [google_project_service.apis]
}

resource "google_pubsub_topic" "pipeline_finished" {
  name   = var.random_suffix ? "crmint-3-pipeline-finished-${random_id.suffix.hex}" : "crmint-3-pipeline-finished"
  labels = var.labels

  depends_on = [google_project_service.apis]
}

resource "random_id" "pubsub_verification_token" {
  byte_length = 16
}

resource "google_pubsub_subscription" "subscriptions" {
  for_each = local.subscriptions

  labels = var.labels
  name   = var.random_suffix ? "${each.key}-subscription-${random_id.suffix.hex}" : "${each.key}-subscription"
  topic  = google_pubsub_topic.topics[each.key].id

  ack_deadline_seconds = each.value.ack_deadline_seconds
  expiration_policy {
    ttl = "" # Stands for "never".
  }
  retry_policy {
    minimum_backoff = "${each.value.minimum_backoff}s"
  }

  push_config {
    oidc_token {
      audience              = google_iap_client.default.client_id
      service_account_email = google_service_account.pubsub_sa.email
    }

    push_endpoint = "${each.value.endpoint}?token=${random_id.pubsub_verification_token.b64_url}"
  }

  depends_on = [google_project_service.apis]
}
