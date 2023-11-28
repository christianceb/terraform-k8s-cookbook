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
