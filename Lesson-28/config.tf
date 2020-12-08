provider "aws" {
    region = "us-east-1"
}
terraform {
  backend "s3"{
      bucket="my-tfstate-bucket-2310" # √ vesioning, SSE-S3 (AWS S3 Key) 
      key="old-all/terraform.tfstate" # Object name to save in bucket Terraform state
      region="us-east-1"              # region where bucket is created
  }
}