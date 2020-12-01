provider "aws" {
  region                  = "us-west-2" #"us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default" # "la-sandbox"
}

terraform {
  backend "s3" {
    bucket = "my-terraform-2310202" #"terraform-state-2310202"
    key    = "dev/network/terraform.tfstate"
    region = "us-west-2"
  }
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "My VPC"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}
output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}
