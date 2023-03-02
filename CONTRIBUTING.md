# Contributing

We'd love to accept your patches and contributions to this project. There are
just a few small guidelines you need to follow.

## Contributor License Agreement

Contributions to this project must be accompanied by a Contributor License
Agreement (CLA). You (or your employer) retain the copyright to your
contribution; this simply gives us permission to use and redistribute your
contributions as part of the project. Head over to
<https://cla.developers.google.com/> to see your current agreements on file or
to sign a new one.

You generally only need to submit a CLA once, so if you've already submitted one
(even if it was for a different project), you probably don't need to do it
again.

## Code Reviews

All submissions, including submissions by project members, require review. We
use GitHub pull requests for this purpose. Consult
[GitHub Help](https://help.github.com/articles/about-pull-requests/) for more
information on using pull requests.

## Development

The following dependencies must be installed on the development system:

- [Docker Engine][docker-engine]
- [Google Cloud SDK][google-cloud-sdk]
- [make]

### Generating Documentation for Inputs and Outputs

The Inputs and Outputs tables in the READMEs of the root module,
submodules, and example modules are automatically generated based on
the `variables` and `outputs` of the respective modules. These tables
must be refreshed if the module interfaces are changed.

#### Execution

Run `make generate_docs` to generate new Inputs and Outputs tables.

### Integration Testing

Integration tests are used to verify the behaviour of the root module,
submodules, and example modules. Additions, changes, and fixes should
be accompanied with tests.

The integration tests are run using [Kitchen][kitchen],
[Kitchen-Terraform][kitchen-terraform], and [InSpec][inspec]. These
tools are packaged within a Docker image for convenience.

The general strategy for these tests is to verify the behaviour of the
[example modules](./examples/), thus ensuring that the root module,
submodules, and example modules are all functionally correct.

#### Test Environment

The easiest way to test the module is in an isolated test project. You can follow the steps in the colab: https://codelabs.developers.google.com/cft-onboarding/

To use this setup, you need a service account with these permissions (on a Folder or Organization):
- Project Creator
- Project Billing Manager

The service account also needs to have the following role on the billing account:
- Billing Account User

The project that the service account belongs to must have the following APIs enabled (the setup won't
create any resources on the service account's project):
- Cloud Resource Manager
- Cloud Billing
- Service Usage
- Identity and Access Management (IAM)

You will also need to set a few environment variables:
```
export TF_VAR_org_id="your_org_id"
export TF_VAR_folder_id="your_folder_id"
export TF_VAR_billing_account="your_billing_account_id"
```

Select your master project

```
gcloud config set core/project YOUR_PROJECT_ID
```

Enable the following Google Cloud APIs on your seed project:

```
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudbilling.googleapis.com
```

Create Service Account

```
gcloud iam service-accounts create cft-onboarding \
  --description="CFT Onboarding Terraform Service Account" \
  --display-name="CFT Onboarding"
export SERVICE_ACCOUNT=cft-onboarding@$(gcloud config get-value core/project).iam.gserviceaccount.com
```

Grant the necessary roles

```
gcloud resource-manager folders add-iam-policy-binding ${TF_VAR_folder_id} \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/resourcemanager.projectCreator"
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/billing.user"
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/resourcemanager.organizationViewer"
gcloud alpha billing accounts add-iam-policy-binding ${TF_VAR_billing_account} \
  --member "serviceAccount:${SERVICE_ACCOUNT}" \
  --role roles/billing.user
```

Export the Service Account credentials to your environment like so:

```
gcloud iam service-accounts keys create cft.json --iam-account=${SERVICE_ACCOUNT}
export SERVICE_ACCOUNT_JSON=$(< cft.json)
rm -rf cft.json
```

With these settings in place, you can prepare a test project using Docker:
```
make docker_test_prepare
```

#### Noninteractive Execution

Run `make docker_test_integration` to test all of the example modules
noninteractively, using the prepared test project.

#### Interactive Execution

1. Run `make docker_run` to start the testing Docker container in
   interactive mode.

1. (Optional) Run `export TF_VAR_iap_brand_id=$(gcloud iap oauth-brands list --project CI_PROJECT_ID --format='value(name)' | sed 's:.*/::')`
   to retrieve the current brand id if one has already been created.

1. Run `cft test run <EXAMPLE_NAME> --stage init --verbose` to initialize the
   working directory for an example module.

1. Run `cft test run <EXAMPLE_NAME> --stage apply --verbose` to apply the
   example module.

1. Run `cft test run <EXAMPLE_NAME> --stage verify --verbose` to test the
   example module.

1. Run `cft test run <EXAMPLE_NAME> --stage teardown --verbose` to destroy the
   example module state.

### Linting and Formatting

Many of the files in the repository can be linted or formatted to
maintain a standard of quality.

#### Execution

Run `make docker_test_lint`.

[docker-engine]: https://www.docker.com/products/docker-engine
[flake8]: http://flake8.pycqa.org/en/latest/
[gofmt]: https://golang.org/cmd/gofmt/
[google-cloud-sdk]: https://cloud.google.com/sdk/install
[hadolint]: https://github.com/hadolint/hadolint
[inspec]: https://inspec.io/
[kitchen-terraform]: https://github.com/newcontext-oss/kitchen-terraform
[kitchen]: https://kitchen.ci/
[make]: https://en.wikipedia.org/wiki/Make_(software)
[shellcheck]: https://www.shellcheck.net/
[terraform-docs]: https://github.com/segmentio/terraform-docs
[terraform]: https://terraform.io/
