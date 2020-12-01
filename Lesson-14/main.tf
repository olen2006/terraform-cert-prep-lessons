#----------------------------------------------------------
# My Terraform
#
# Local Variables
#
# 11.29.2020
#----------------------------------------------------------

provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "la-sandbox"
}

data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

locals {
  full_project_name = "${var.env}-${var.project_name}"
  project_owner     = "${var.owner} owner of ${var.project_name}"
}
locals {
  country  = "Canada"
  city     = "Calgary"
  az_list  = join(",", data.aws_availability_zones.available.names) # list all azs
  region   = data.aws_region.current.description                    #US East (N. Virginia)
  location = "In ${local.region} there are AZ's: ${local.az_list}"
}
resource "aws_eip" "my_static_ip" {
  tags = {
    Name       = "Static IP"
    Owner      = var.owner
    Project    = local.full_project_name # "${var.env}-${var.project_name}"
    proj_owner = local.project_owner
    city       = local.city
    region_azs = local.location
  }
}
