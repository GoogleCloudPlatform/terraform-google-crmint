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

##
# Report usage analytics consent

variable "report_usage" {
  description = "Report anonymous usage to our analytics to improve the tool."
  type        = bool
  default     = false
}


##
# Application config

variable "app_title" {
  description = "Project name to display in the UI."
  type        = string
  default     = "CRMint App"
}

variable "notification_sender_email" {
  description = "Email address to send notifications to."
  type        = string
}


##
# Security (IAP configuration)

variable "iap_brand_id" {
  description = "Existing IAP Brand ID - only INTERNAL TYPE (you can obtain it using this command: `$ gcloud iap oauth-brands list --format='value(name)' | sed 's:.*/::'`)."
  type        = string
  default     = null
}

variable "iap_support_email" {
  description = "Support email used for configuring IAP"
  type        = string
}

variable "iap_allowed_users" {
  description = "Lost of IAP allowed users."
  type        = list(any)
}


##
# Google Cloud Project

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-east1"
}


##
# Virtual Private Cloud

variable "use_vpc" {
  description = "Configures the database with a private IP. Default to true."
  type        = bool
  default     = true
}

variable "network_project_id" {
  description = "Network GCP project to use. Defaults to `var.project_id`."
  type        = string
  default     = null
}

variable "network_region" {
  description = "Network region. Defaults to `var.region`."
  type        = string
  default     = null
}


##
# Database

variable "database_project_id" {
  description = "Database GCP project to use. Defaults to `var.project_id`."
  type        = string
  default     = null
}

variable "database_region" {
  description = "Database region to setup a Cloud SQL instance. Defaults to `var.region`"
  type        = string
  default     = null
}

variable "database_tier" {
  description = "Database instance machine tier. Defaults to a small instance."
  type        = string
  default     = "db-g1-small"
}

variable "database_availability_type" {
  description = "Database availability type. Defaults to one zone."
  type        = string
  default     = "ZONAL"
}

variable "database_instance_name" {
  description = "Name for the Cloud SQL instance."
  type        = string
  default     = "crmint-3-db"
}

variable "database_name" {
  description = "Name of the database in your Cloud SQL instance."
  type        = string
  default     = "crmintapp-db"
}

variable "database_user" {
  description = "Database user name."
  type        = string
  default     = "crmintapp"
}


##
# Services Docker images

variable "frontend_image" {
  description = "Docker image uri (with tag) for the frontend service"
  type        = string
  default     = "europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/frontend:master"
}

variable "controller_image" {
  description = "Docker image uri (with tag) for the controller service"
  type        = string
  default     = "europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/controller:master"
}

variable "jobs_image" {
  description = "Docker image uri (with tag) for the jobs service"
  type        = string
  default     = "europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/jobs:master"
}


##
# Blueprint specifics

variable "random_suffix" {
  description = "Add random suffix to deployed resources (to allow multiple deployments per project)"
  type        = string
  default     = true
}

variable "goog_bc_deployment_name" {
  description = "This is only set if run via BC/CM"
  type        = string
  default     = ""
}

variable "labels" {
  description = "A set of key/value label pairs to assign to the resources deployed by this blueprint."
  default     = {}
  type        = map(string)
}
