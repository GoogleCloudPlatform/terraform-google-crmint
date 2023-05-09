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

resource "google_cloud_scheduler_job" "heartbeat" {
  name        = var.random_suffix ? "crmint-heartbeat-${random_id.suffix.hex}" : "crmint-heartbeat"
  description = "Triggers scheduled pipeline runs - Managed by ${local.managed_by_desc}"

  schedule = "* * * * *"
  project  = var.project_id

  pubsub_target {
    topic_name = lookup(google_pubsub_topic.topics, "crmint-3-start-pipeline").id
    data       = base64encode("{\"pipeline_ids\": \"scheduled\"}")
    attributes = {
      start_time = 0
    }
  }
}
