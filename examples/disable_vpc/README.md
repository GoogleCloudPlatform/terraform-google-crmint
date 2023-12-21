# Disable VPC Deployment Example

This example illustrates how to use the `crmint` module wihtout the VPC feature.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| caller\_identity | Email of the caller, used to configure IAP. | `any` | n/a | yes |
| iap\_brand\_id | Existing IAP Brand ID. | `any` | `null` | no |
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |
| region | GCP Region | `string` | `"us-east1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| project\_id | GCP Project ID |
| region | Region used to deploy CRMint. |
| report\_usage\_id | Report Usage ID (empty if opt-out) |
| secured\_url | The url to access CRMint UI (with Google Managed certificate). |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
