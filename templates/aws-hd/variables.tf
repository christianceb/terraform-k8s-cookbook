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

variable "use_ebs_volume" {
  default = false
  type = bool
}

variable "development_ebs_volume_gbs" {
  default = 20
  type = number
}

variable "do_token" {
  description = "A DigitalOcean token to be used when provisioning subdomains. (reference: https://docs.digitalocean.com/reference/api/create-personal-access-token/)"
}

variable "domain" {
  description = "The domain to use to append to the subdomain. Note that this domain must exist on the DigitalOcean account tied to the token"
}

variable "subdomain" {
  description = "The subdomain to be prepended to the domain"
}
