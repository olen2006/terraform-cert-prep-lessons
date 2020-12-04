#----------------------------------------------------------
# My Terraform
# Flobal variables in Remote state on S3
#
# 12.03.2020
#----------------------------------------------------------

provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    bucket = "my-terraform-state-bucket-01"
    key    = "globalvars/terraform.tfstate"
    region = "us-east-1"
  }
}

#  we can pull global vars using
## data.terraform_remote_state.global.outputs.global_company_name
# or using locals
locals {
  company_name = data.terraform_remote_state.global.outputs.global_company_name
  owner        = data.terraform_remote_state.global.outputs.global_owner
  common_tags  = data.terraform_remote_state.global.outputs.global_tags
}

#-----------------------------------------------------------
resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name    = "Stack1-VPC1"
    Company = local.company_name
    Owner   = local.owner
  }
}

resource "aws_vpc" "vpc2" {
  cidr_block = "10.0.0.0/16"
  tags       = merge(local.common_tags, { Name = "Stack1-VPC1" })
}
