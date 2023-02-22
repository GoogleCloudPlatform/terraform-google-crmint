# Standard Deployment Example

This example illustrates how to use the `crmint` module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| caller\_identity | Email of the caller, used to configure IAP. | `any` | n/a | yes |
| iap\_brand\_id | Existing IAP Brand ID. | `any` | `null` | no |
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |
| region | GCP Region | `string` | `"us-east1"` | no |
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
