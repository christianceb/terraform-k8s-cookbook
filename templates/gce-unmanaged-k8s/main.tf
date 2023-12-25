terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.7.0"
    }
  }
}

data "google_compute_image" "ubuntu" {
  # Values pulled from `gcloud compute images list`
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc" {
  name                    = "${var.prefix}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "vpc-subnet" {
  name          = "${google_compute_network.vpc.name}-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc.id
}

resource "google_compute_firewall" "vpc-firewall" {
  name          = "${google_compute_network.vpc.name}-firewall"
  network       = google_compute_network.vpc.self_link
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "all"
  }
}

resource "google_service_account" "sa" {
  account_id   = "${var.prefix}-sa"
  display_name = "${var.prefix} Service Account"
}

resource "google_project_iam_member" "sa-editor-binding" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_compute_project_metadata" "ssh_keys" {
  metadata = {
    ssh-keys = join("\n", [for user, key_file in var.ssh_keys : "${user}:${file(key_file)}"])
  }
}

resource "google_compute_instance_template" "k8s_node_template" {
  machine_type = var.machine_type

  network_interface {
    access_config {
      network_tier = "STANDARD"
    }

    subnetwork = google_compute_subnetwork.vpc-subnet.self_link
  }

  disk {
    source_image = data.google_compute_image.ubuntu.self_link
    disk_size_gb = 20
    disk_type    = "pd-standard"
  }

  service_account {
    email = google_service_account.sa.email
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
      # "cloud-platform", # Grant all service scopes with (may be dangerous)
    ]
  }
}

resource "google_compute_instance_from_template" "primus" {
  name = "primus"

  source_instance_template = google_compute_instance_template.k8s_node_template.self_link_unique

  desired_status = var.instance_desired_status
}

# resource "google_compute_instance_from_template" "secundus" {
#   name = "secundus"

#   source_instance_template = google_compute_instance_template.k8s_node_template.self_link_unique
# }
