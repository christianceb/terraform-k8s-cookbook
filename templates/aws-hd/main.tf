terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  ## TODO: option to move state to AWS S3
  # backend "aws" {}
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

locals {
  availability_zone = "${var.region}a"
}

resource "tls_private_key" "primary_key_pair" {
  algorithm = "ED25519"
}

output "primary_private_key" {
  value     = tls_private_key.primary_key_pair.private_key_openssh
  sensitive = true
}

output "primary_public_key" {
  value     = tls_private_key.primary_key_pair.public_key_openssh
}

resource "aws_key_pair" "primary_ssh_key" {
  key_name   = "primary"
  public_key = tls_private_key.primary_key_pair.public_key_openssh
}

# resource "aws_key_pair" "secondary_ssh_keys" {
#   count = var.ssh_keys == null ? 0 : length(var.ssh_keys)

#   key_name   = keys(var.ssh_keys)[count.index]
#   public_key = file(values(var.ssh_keys)[count.index])
# }

resource "aws_vpc" "this" {
  tags = {
    Name = "primary-vpc"
  }

  enable_dns_hostnames = true

  cidr_block = "10.0.0.0/24"
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-internet-gateway"
  }
}

resource "aws_subnet" "this" {
  tags = {
    Name = "${aws_vpc.this.tags.Name}-subnet"
  }

  availability_zone = local.availability_zone
  cidr_block        = aws_vpc.this.cidr_block
  vpc_id            = aws_vpc.this.id

  depends_on = [aws_internet_gateway.this]
}

resource "aws_security_group" "allow-ssh-http-outgoing-all" {
  name        = "ssh-http-outgoing-all"
  description = "Allow SSH, HTTP and all outgoing on this SG"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow SSH, HTTP and all outgoing traffic"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-${var.ubuntu_code_name}-*"]
  }

  filter {
    name   = "architecture"
    values = [var.architecture]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.this.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.this.id}"
  }

  tags = {
    Name = "rt-public"
  }
}

resource "aws_route_table_association" "rt-public-subnet" {
  subnet_id      = "${aws_subnet.this.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# resource "aws_ebs_volume" "development_volume" {
#   availability_zone = local.availability_zone
#   size              = var.development_ebs_volume_gbs

#   tags = {
#     Name = "development_volume"
#   }
# }

# TODO: prevent /dev/sda1 automatically getting populated. maybe check https://www.reddit.com/r/Terraform/comments/wu92wb/creating_aws_instance_from_ami_instantly_failing/
resource "aws_instance" "development" {
  tags = {
    Name = "development"
  }

  availability_zone = local.availability_zone
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.instance_type
  subnet_id         = aws_subnet.this.id
  key_name          = aws_key_pair.primary_ssh_key.key_name
  vpc_security_group_ids = [ aws_security_group.allow-ssh-http-outgoing-all.id ]

  user_data = data.cloudinit_config.server_config.rendered
}

data "cloudinit_config" "server_config" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = file("first-run.yaml")
  }
}

## Parked for future debugging
# resource "aws_volume_attachment" "development_volume_attachment" {
#   device_name = "/dev/sda1"
#   instance_id = aws_instance.development.id
#   volume_id   = aws_ebs_volume.development_volume.id
# }

resource "aws_eip" "elastic_ip" {
  instance = aws_instance.development.id

  depends_on = [aws_internet_gateway.this]
}

## Parked for later use
# resource "aws_s3_bucket" "demo" {
#   # bucket = "my-tf-test-bucket"

#   tags = {
#     Name        = "My bucket"
#     Environment = "Dev"
#   }
# }
