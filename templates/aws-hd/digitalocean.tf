provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_domain" "bsdl-xyz" {
  name = var.domain
}

resource "digitalocean_record" "subdomain" {
  domain = data.digitalocean_domain.bsdl-xyz.id
  type = "A"
  name = "${var.subdomain}"
  value = aws_eip.elastic_ip.public_ip
}

output "domain_name" {
  value = digitalocean_record.subdomain.fqdn
}
