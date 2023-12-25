variable "project_id" {}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "prefix" {
  default = "gce-unmanaged-k8s"
}

variable "machine_type" {
  default = "e2-medium"
}

variable "ssh_keys" {
  type = map(string)
}

variable "instance_desired_status" {
  # See: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#desired_status
  default = "RUNNING"
}
