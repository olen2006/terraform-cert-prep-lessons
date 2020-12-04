#----------------------------------------------------------
# My Terraform
#
# Remote State on S3
#
# S3 bucket created manually then point to it in the code
# Enable bucket versioning and encryption
# 02.12.2020
# in case of error 
#
#   Error refreshing state: AccessDenied: Access Denied
#        status code: 403, request id: DAA19D2D2C6D9DCD, host id: zaYiyR3rHXRee2ltbMWVKdtaUIwVEOMbzfZOLLwaO2XqAnTff/QCu0pzByQAxqi3jj7yOESoaPw=
#
# use export AWS_ACCESS_KEY_ID=
# and export AWS_SECRET_ACCESS_KEY=
# env| grep AWS_
# unset AWS_ACCESS_KEY_ID if ineeded
#----------------------------------------------------------

provider "aws" {
  region                  = "us-east-1" 
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "la-sandbox" #
}

# Remote state storing on S3
terraform {
  backend "s3" {
    bucket = "my-terraform-23102"            # Bucket where to SAVE Terraform State
    key    = "dev/network/terraform.tfstate" # Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                     # Region where bycket created
  }
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "env" {
  default = "dev"
}

variable "public_subnet_sidrs" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_sidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_sidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-${count.index + 1}"
  }
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.env}-routing-public-subnets"
  }
}

resource "aws_route_table_association" "public_route" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
}

#----------------------------------------------------------
output "vpc_id" {
  value = aws_vpc.main.id
}
output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}
output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id

}
