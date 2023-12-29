# gcp-state-buckets

Use Google Cloud Storage to store Terraform State. Projects does not have to be with Google Cloud as it is merely storing the state in the cloud. Make sure that you have `gcloud` CLI configured for it to work. 

## Getting Started

- Instantiate with `terraform init` on this folder
- Make a `terraform.tfvars` file to define target `project_id` and `buckets` where desired
- Run `terraform plan` to validate
- Apply with `terraform apply`

## Moving state from `local` to `gcs`
Some, if not all templates and even this template can utilise `gcs` to store state. To do this, you need to have an existing local state on a template.

Using this template as example, either create a `backend.tf` file or modify `main.tf` to include the following:

```diff
terraform {
+ backend "gcs" {
+   bucket = "state-buckets-self"
+ }
}

# For more information on `state-buckets-self`, see `variables.tf` under `self_bucket`
```

Afterwards, run `terraform init -migrate-state` and follow the prompt to complete.
