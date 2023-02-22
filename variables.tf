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

variable "report_usage_id" {
  description = "Report anonymous usage to our analytics to improve the tool."
  nullable    = false
}


##
# Application config

variable "app_title" {
  description = "Project name to display in the UI."
  default     = "CRMint App"
}

variable "notification_sender_email" {
  description = "Email address to send notifications to."
}


##
# Security (IAP configuration)

variable "iap_brand_id" {
  description = "Existing IAP Brand ID - only INTERNAL TYPE (you can obtain it using this command: `$ gcloud iap oauth-brands list --format='value(name)' | sed 's:.*/::'`)."
  default = null
}

variable "iap_support_email" {
  description = "Support email used for configuring IAP"
}

variable "iap_allowed_users" {
  type = list
}


##
# Google Cloud Project

variable "project_id" {
  description = "GCP Project ID"
}

variable "region" {
  description = "GCP Region"
  default = "us-east1"
}


##
# Virtual Private Cloud

variable "use_vpc" {
  description = "Configures the database with a private IP. Default to true."
  default = true
}

variable "network_project_id" {
  description = "Network GCP project to use. Defaults to `var.project_id`."
  default = null
}

variable "network_region" {
  description = "Network region. Defaults to `var.region`."
  default = null
}


##
# Database

variable "database_project_id" {
  description = "Database GCP project to use. Defaults to `var.project_id`."
  default = null
}

variable "database_region" {
  description = "Database region to setup a Cloud SQL instance. Defaults to `var.region`"
  default = null
}

variable "database_tier" {
  description = "Database instance machine tier. Defaults to a small instance."
  default = "db-g1-small"
}

variable "database_availability_type" {
  description = "Database availability type. Defaults to one zone."
  default = "ZONAL"
}

variable "database_instance_name" {
  description = "Name for the Cloud SQL instance."
  default = "crmint-3-db"
}

variable "database_name" {
  description = "Name of the database in your Cloud SQL instance."
  default = "crmintapp-db"
}

variable "database_user" {
  description = "Database user name."
  default = "crmintapp"
}


##
# Services Docker images

variable "frontend_image" {
  description = "Docker image uri (with tag) for the frontend service"
  default = "europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/frontend:master"
}

variable "controller_image" {
  description = "Docker image uri (with tag) for the controller service"
  default = "europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/controller:master"
}

variable "jobs_image" {
  description = "Docker image uri (with tag) for the jobs service"
  default = "europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/jobs:master"
}
