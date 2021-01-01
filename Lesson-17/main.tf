#----------------------------------------------------------
# My Terraform
#
# Terraform Conditions and Lookups
# instance_type = var.env == "prod" ? "t3.small" : "t2.micro"
# 29.11.2020
#----------------------------------------------------------
provider "aws" {
  region                  = var.region #"us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "la-sandbox" # "la-sandbox"
}

data "aws_ami" "latest_amazon_linux_2" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # always get the latest version
  }
}

resource "aws_instance" "my_webserver1" {
  ami = data.aws_ami.latest_amazon_linux_2.id
  #instance_type = var.env == "prod" ? "t3.small" : "t2.micro"
  instance_type = var.env == "prod" ? var.ec2_size["prod"] : var.ec2_size["dev"] # or hard code
  tags = {
    Name  = "${var.env}-server"
    Owner = var.env == "prod" ? var.prod_owner : var.noprod_owner
  }
}

# Create Bastion only in Dev environment
resource "aws_instance" "my_dev_bastion" {
  count         = var.env == "dev" ? 1 : 0
  ami           = data.aws_ami.latest_amazon_linux_2.id
  instance_type = "t2.micro" # var.env == "prod" ? "t3.small" : "t2.micro"
  tags = {
    Name = "Bastion Server for Dev-server"

  }
}

## Lookup Example
resource "aws_instance" "my_webserver2" {
  ami           = data.aws_ami.latest_amazon_linux_2.id
  instance_type = lookup(var.ec2_size, var.env)
  tags = {
    Name  = "${var.env}-server"
    Owner = var.env == "prod" ? var.prod_owner : var.noprod_owner
  }
}

resource "aws_security_group" "my_webserver" {
  name        = "Dynamic-SG"
  description = "Dynamic Security Group"
  dynamic "ingress" {
    for_each = lookup(var.allow_port_list, var.env)
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "Dynamic Security Group"
    Owner = "Walter Sobchak"
  }
}
