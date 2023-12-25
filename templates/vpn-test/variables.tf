variable "project_id" {}

variable "region" {
  default = "southamerica-east1"
}

variable "zone" {
  default = "southamerica-east1-a"
}

variable "prefix" {
  default = "vpn"
}

variable "machine_type" {
  default = "e2-medium"
}

variable "ssh_keys" {
  type = map(string)
}
