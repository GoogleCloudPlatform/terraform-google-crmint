# terraform-google-crmint

## Description
### tagline
Terraform Module to deploy the [CRMint application](https://google.github.io/crmint).

### detailed
This module configures your GCP project to host a [CRMint application](https://google.github.io/crmint).

The resources/services/activations/deletions that this module will create/trigger are:

- Cloud Run Services (3)
- Cloud Scheduler Job (1)
- CloudBuild Worker Pool (1)
- Cloud HTTPS Load Balancer (1)
- Compute Global IP Address (1)
- Compute Managed SSL Certificate (1)
- IAP Authentication (1)
- Logging Metric (1)
- Monitoring Alert Policy (1)
- Monitoring Notification Channel (1)
- Pub/Sub Subscription (1)
- Pub/Sub Topics (2)
- Secret Manager Secret (1)
- Service Accounts (4)
- SQL Database Instance (1)
- VPC Access Connector (1)

### preDeploy
To deploy this blueprint you must have an active billing account and billing permissions.

## Documentation
- [CRMint application](https://google.github.io/crmint) built by gTech Professional Services from Google Ads (**not an official product**).

## Usage

Basic usage of this module is as follows:

```hcl
module "crmint" {
  source  = "terraform-google-modules/crmint/google"
  version = "~> 0.1"

  app_title                 = "My Local Custom App"
  notification_sender_email = "me@example.com"

  # Google Cloud Platform.
  project_id                = "YOUR_PROJECT_ID"
  region                    = "GCP_REGION"  # e.g. us-east1
  database_instance_name    = "crmint-3-db"
  use_vpc                   = true

  # Docker service images (in case you want to pin to a specific version).
  frontend_image            = "europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/frontend:master"
  controller_image          = "europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/controller:master"
  jobs_image                = "europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/jobs:master"

  # User access management.
  iap_support_email         = "me@example.com"
  iap_allowed_users         = [
                                "user:me@example.com",
                                "user:john@example.com",
                                "user:kate@example.com",
                              ]
}
```

Functional examples are included in the
[examples](./examples/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_title | Project name to display in the UI. | `string` | `"CRMint App"` | no |
| controller\_image | Docker image uri (with tag) for the controller service | `string` | `"europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/controller:master"` | no |
| database\_availability\_type | Database availability type. Defaults to one zone. | `string` | `"ZONAL"` | no |
| database\_instance\_name | Name for the Cloud SQL instance. | `string` | `"crmint-3-db"` | no |
| database\_name | Name of the database in your Cloud SQL instance. | `string` | `"crmintapp-db"` | no |
| database\_project\_id | Database GCP project to use. Defaults to `var.project_id`. | `string` | `null` | no |
| database\_region | Database region to setup a Cloud SQL instance. Defaults to `var.region` | `string` | `null` | no |
| database\_tier | Database instance machine tier. Defaults to a small instance. | `string` | `"db-g1-small"` | no |
| database\_user | Database user name. | `string` | `"crmintapp"` | no |
| frontend\_image | Docker image uri (with tag) for the frontend service | `string` | `"europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/frontend:master"` | no |
| goog\_bc\_deployment\_name | This is only set if run via BC/CM | `string` | `""` | no |
| iap\_allowed\_users | List of user email addresses that should be allowed to use the CRMint UI | `list(string)` | n/a | yes |
| iap\_brand\_id | Existing IAP Brand ID - only INTERNAL TYPE (you can obtain it using this command: `$ gcloud iap oauth-brands list --format='value(name)' | sed 's:.*/::'`). | `string` | `null` | no |
| iap\_support\_email | Support email used for configuring IAP | `string` | n/a | yes |
| jobs\_image | Docker image uri (with tag) for the jobs service | `string` | `"europe-docker.pkg.dev/instant-bqml-demo-environment/crmint/jobs:master"` | no |
| labels | A set of key/value label pairs to assign to the resources deployed by this blueprint. | `map(string)` | `{}` | no |
| network\_project\_id | Network GCP project to use. Defaults to `var.project_id`. | `string` | `null` | no |
| network\_region | Network region. Defaults to `var.region`. | `string` | `null` | no |
| notification\_sender\_email | Email address to send notifications to. | `string` | n/a | yes |
| project\_id | GCP Project ID | `string` | n/a | yes |
| random\_suffix | Add random suffix to deployed resources (to allow multiple deployments per project) | `string` | `true` | no |
| region | GCP Region | `string` | `"us-east1"` | no |
| report\_usage | Report anonymous usage to our analytics to improve the tool. | `bool` | `false` | no |
| use\_vpc | Configures the database with a private IP. Default to true. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloud\_db\_uri | Database connection URI. |
| project\_id | GCP Project ID |
| region | Region used to deploy CRMint. |
| report\_usage\_id | Report Usage ID (empty if opt-out) |
| secured\_url | The url to access CRMint UI (with Google Managed certificate). |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.0

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Storage Admin: `roles/storage.admin`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Google Cloud Storage JSON API: `storage-api.googleapis.com`

The [Project Factory module][project-factory-module] can be used to
provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).
