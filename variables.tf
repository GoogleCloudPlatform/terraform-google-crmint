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
  default     = false
  type        = bool
}


##
# Application config

variable "app_title" {
  description = "Project name to display in the UI."
  default     = "CRMint App"
  type        = string
}

variable "notification_sender_email" {
  description = "Email address to send notifications to."
  type        = string
}


##
# Security (IAP configuration)

variable "iap_brand_id" {
  description = "Existing IAP Brand ID - only INTERNAL TYPE (you can obtain it using this command: `$ gcloud iap oauth-brands list --format='value(name)' | sed 's:.*/::'`)."
  default     = null
  type        = string
}

variable "iap_support_email" {
  description = "Support email used for configuring IAP"
  type        = string
}

variable "iap_allowed_users" {
  description = "List of user email addresses that should be allowed to use the CRMint UI"
  type        = list(string)
}


##
# Google Cloud Project

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  default     = "us-east1"
  type        = string
}


##
# Virtual Private Cloud

variable "use_vpc" {
  description = "Configures the database with a private IP. Default to true."
  default     = true
  type        = bool
}

variable "network_project_id" {
  description = "Network GCP project to use. Defaults to `var.project_id`."
  default     = null
  type        = string
}

variable "network_region" {
  description = "Network region. Defaults to `var.region`."
  default     = null
  type        = string
}


##
# Database

variable "database_project_id" {
  description = "Database GCP project to use. Defaults to `var.project_id`."
  default     = null
  type        = string
}

variable "database_region" {
  description = "Database region to setup a Cloud SQL instance. Defaults to `var.region`"
  default     = null
  type        = string
}

variable "database_tier" {
  description = "Database instance machine tier. Defaults to a small instance."
  default     = "db-g1-small"
  type        = string
}

variable "database_availability_type" {
  description = "Database availability type. Defaults to one zone."
  default     = "ZONAL"
  type        = string
}

variable "database_instance_name" {
  description = "Name for the Cloud SQL instance."
  default     = "crmint-3-db"
  type        = string
}

variable "database_name" {
  description = "Name of the database in your Cloud SQL instance."
  default     = "crmintapp-db"
  type        = string
}

variable "database_user" {
  description = "Database user name."
  default     = "crmintapp"
  type        = string
}


##
# Services Docker images

variable "frontend_image" {
  description = "Docker image uri (with tag) for the frontend service"
  default     = "europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/frontend:master"
  type        = string
}

variable "controller_image" {
  description = "Docker image uri (with tag) for the controller service"
  default     = "europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/controller:master"
  type        = string
}

variable "jobs_image" {
  description = "Docker image uri (with tag) for the jobs service"
  default     = "europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/jobs:master"
  type        = string
}


##
# Blueprint specifics

variable "random_suffix" {
  description = "Add random suffix to deployed resources (to allow multiple deployments per project)"
  default     = true
  type        = string
}

variable "goog_bc_deployment_name" {
  description = "This is only set if run via BC/CM"
  default     = ""
  type        = string
}

variable "labels" {
  description = "A set of key/value label pairs to assign to the resources deployed by this blueprint."
  default     = {}
  type        = map(string)
}
