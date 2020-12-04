#----------------------------------------------------------
# My Terraform
# Flobal variables in Remote state on S3
#
# 12.03.2020
#----------------------------------------------------------
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket-01" # encryption & versioning enabled
    key    = "globalvars/terraform.tfstate"
    region = "us-east-1"
  }
}
#==========================================================
output "global_company_name" {
  value = "Dimond Soft International"
}
output "global_owner" {
  value = "Walter Sobchak"
}
output "global_tags" {
  value = {
    Project    = "Assembly-2020"
    CostCenter = "R&D"
    Country    = "Canada"
  }
}
