# Terraform K8s Cookbook

Terraform scripts to assist in learning K8s via disposable environments.

## Requirements
1. Terraform — `v1.6.4` or above
2. `gcloud` — if using Google Cloud recipes. Must be configured and authenticated

## Google Cloud

### `gcp-token.sh` — Helper tool for managing GCP Access Tokens

Service Account keys are intended to be banned from this cookbook.

### Google Compute Engine Unmanaged K8s (`gce-unmanaged-k8s`)

- VPC + Subnet + Firewall
- Two nodes/compute engines (`primus`, `secundus` (WIP)). `tertius` a possibility.
- Can accept public keys to automatically assign as `ssh` users
- Cost effective
- Slightly inconvenient to setup (very manual, may automate in the future with a shell script)

#### Example `terraform.tfvars`
```terraform
project_id = "cookbook"
ssh_keys = {
  john = "~/.ssh/id_rsa.pub"
}
```

Refer to `templates/gce-unmanaged-k8s/variables.tf` for overrides and definition

#### Usage:
1. Note down your GCP project ID (create a project if you havent yet)
2. On `templates/gce-unmanaged-k8s`, Create `terraform.tfvars`
3. Pass `project_id` with the value retrieved earlier.
4. Create `ssh_keys` with your values of choice
5. Run:
   1. `terraform init` if running for the first time, 
   2. `terraform validate`
   3. `terraform plan`
   4. `terraform apply` to finally apply changes

### [Planned] Google Kubernetes Engine (`gke`)

- VPC + Subnet + Firewall
- GKE
- Two nodes
- Convenient to use
- Pricier (it costs to run GKE Control Plane)
