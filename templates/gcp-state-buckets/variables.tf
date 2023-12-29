variable "project_id" {}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "self_bucket" {
  default = "state-buckets-self"
}

variable "buckets" {
  default = []
}

