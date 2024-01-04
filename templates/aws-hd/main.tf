terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
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

resource "aws_key_pair" "primary_ssh_key" {
  key_name   = "primary"
  public_key = tls_private_key.primary_key_pair.public_key_openssh
}

resource "aws_key_pair" "secondary_ssh_keys" {
  count = var.ssh_keys == null ? 0 : length(var.ssh_keys)

  key_name   = keys(var.ssh_keys)[count.index]
  public_key = file(values(var.ssh_keys)[count.index])
}

resource "aws_vpc" "vpc" {
  tags = {
    Name = "primary-vpc"
  }

  cidr_block = "10.0.0.0/24"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${aws_vpc.vpc.tags.Name}-internet-gateway"
  }
}

resource "aws_subnet" "subnet" {
  tags = {
    Name = "${aws_vpc.vpc.tags.Name}-subnet"
  }

  availability_zone = local.availability_zone
  cidr_block        = "10.0.0.0/24"
  vpc_id            = aws_vpc.vpc.id

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_security_group" "security_group" {
  name        = "primary-security-group"
  description = "Allow all traffic in this security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow all incoming traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
    Name = "Primary - allow all traffic"
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

resource "aws_ebs_volume" "development_volume" {
  availability_zone = local.availability_zone
  size              = var.development_ebs_volume_gbs

  tags = {
    Name = "development_volume"
  }
}

resource "aws_instance" "development" {
  tags = {
    Name = "development"
  }

  availability_zone = local.availability_zone
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.instance_type
  subnet_id         = aws_subnet.subnet.id
  key_name          = aws_key_pair.primary_ssh_key.key_name
}

resource "aws_volume_attachment" "development_volume_attachment" {
  device_name = "/dev/sda1"
  instance_id = aws_instance.development.id
  volume_id   = aws_ebs_volume.development_volume.id
}

resource "aws_eip" "lb" {
  instance = aws_instance.development.id

  depends_on = [aws_internet_gateway.internet_gateway]
}

## Parked for later use
# resource "aws_s3_bucket" "demo" {
#   # bucket = "my-tf-test-bucket"

#   tags = {
#     Name        = "My bucket"
#     Environment = "Dev"
#   }
# }
