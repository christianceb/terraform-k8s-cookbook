terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.7.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_storage_bucket" "buckets" {
  for_each      = toset(length(var.buckets) > 0 ? concat([var.self_bucket], var.buckets) : [var.self_bucket])
  name          = each.value
  location      = var.region
  force_destroy = true

  versioning {
    enabled = true
  }
}
