variable "project" {
  description = "Define an arbitrary project name in kebab-case (e.g.: cool-project-1436)"
}

variable "profile" {
  description = "The aws-cli profile name to use for this operation"
}

variable "region" {
  description = "The target region for the operations. Any operation requiring a specific availability zone will default to \"a\""
  default = "us-east-2"
}

variable "ssh_keys" {
  type = map(string)
  nullable = true
}

variable "architecture" {
  default = "x86_64" # can also use arm64
}

variable "ubuntu_code_name" {
  default = "jammy"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "development_ebs_volume_gbs" {
  default = 30
  type = number
}
