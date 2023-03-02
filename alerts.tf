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

resource "google_logging_metric" "pipeline_status_failed" {
  name        = var.random_suffix ? "crmint/pipeline_status_failed-${random_id.suffix.hex}" : "crmint/pipeline_status_failed"
  description = "Managed by ${local.managed_by_desc}"

  filter = "resource.type=cloud_run_revision AND jsonPayload.log_type=PIPELINE_STATUS AND jsonPayload.labels.pipeline_status=failed"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    labels {
      key         = "pipeline_id"
      value_type  = "STRING"
      description = "Pipeline ID"
    }
    labels {
      key         = "message"
      value_type  = "STRING"
      description = "Error message"
    }
    display_name = "Pipeline Status Failed Metric"
  }
  label_extractors = {
    "pipeline_id"     = "EXTRACT(jsonPayload.labels.pipeline_id)"
    "message"         = "EXTRACT(jsonPayload.message)"
  }

  depends_on = [google_project_service.apis]
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notification Channel"
  type         = "email"
  labels = {
    email_address = var.notification_sender_email
  }
  force_delete = false
  enabled      = true

  depends_on = [google_project_service.apis]
}

resource "google_monitoring_alert_policy" "notify_on_pipeline_status_failed" {
  display_name = "Pipeline Status Failed Alert Policy"
  enabled      = true
  combiner     = "OR"
  conditions {
    display_name = "Monitor pipeline errors"
    condition_threshold {
      filter               = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.pipeline_status_failed.id}\" AND resource.type=cloud_run_revision"
      duration             = "60s"
      comparison           = "COMPARISON_GT"
      threshold_value      = 0.001
      trigger {
        count = 1
      }
      aggregations {
        alignment_period     = "60s"
        cross_series_reducer = "REDUCE_NONE"
        per_series_aligner   = "ALIGN_COUNT"
      }
    }
  }
  notification_channels = [google_monitoring_notification_channel.email.id]
  depends_on = [
    google_project_service.apis,
    google_logging_metric.pipeline_status_failed
  ]
}
