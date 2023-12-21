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

module "crmint" {
  source = "GoogleCloudPlatform/crmint/google"
version="~> REPLACE-AFTER-RELEASE"

  report_usage              = true
  app_title                 = "My Local Custom App"
  notification_sender_email = var.caller_identity

  # Google Cloud Platform.
  project_id                = var.project_id
  region                    = var.region  # e.g. us-east1
  database_instance_name    = "crmint-3-db"
  use_vpc                   = true

  # Docker service images (in case you want to pin to a specific version).
  frontend_image            = "europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/frontend:master"
  controller_image          = "europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/controller:master"
  jobs_image                = "europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/jobs:master"

  # User access management.
  iap_brand_id              = var.iap_brand_id
  iap_support_email         = var.caller_identity
  iap_allowed_users         = [
                                "serviceAccount:${var.caller_identity}",
                                # "user:me@example.com",
                              ]
}
