# Simple Example

This example illustrates how to use the `crmint` module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_title | Project name to display in the UI. | `any` | n/a | yes |
| controller\_image | Docker image uri (with tag) for the controller service | `string` | `"europe-docker.pkg.dev/crmint-builds/crmint/controller:latest"` | no |
| frontend\_image | Docker image uri (with tag) for the frontend service | `string` | `"europe-docker.pkg.dev/crmint-builds/crmint/frontend:latest"` | no |
| iap\_allowed\_users | n/a | `list` | n/a | yes |
| iap\_band\_id | Existing IAP Brand ID - only INTERNAL TYPE (you can obtain it using this command: `$ gcloud iap oauth-brands list --format='value(name)' | sed 's:.*/::'`). | `any` | `null` | no |
| iap\_support\_email | Support email used for configuring IAP | `any` | n/a | yes |
| jobs\_image | Docker image uri (with tag) for the jobs service | `string` | `"europe-docker.pkg.dev/crmint-builds/crmint/jobs:latest"` | no |
| notification\_sender\_email | Email address to send notifications to. | `any` | n/a | yes |
| project\_id | GCP Project ID | `any` | n/a | yes |
| region | GCP Region | `string` | `"us-east1"` | no |
| report\_usage\_id | Report anonymous usage to our analytics to improve the tool. | `any` | n/a | yes |
| zone | GCP Zone | `string` | `"us-east1-c"` | no |

## Outputs

| Name | Description |
|------|-------------|
| secured\_url | The url to access CRMint UI (with Google Managed certificate). |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
