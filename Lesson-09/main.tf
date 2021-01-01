######################################
#
# Working with Data Sources 
# https://www.terraform.io/docs/configuration/data-sources.html
######################################
provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "la-sandbox"
}
data "aws_availability_zones" "working" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_vpcs" "my_vpcs" {}
data "aws_vpc" "my_vpc" { tags = { Name = "Prod" } } # filtering VPC with tag

resource "aws_subnet" "prod_subnet_1" {
  vpc_id            = data.aws_vpc.my_vpc.id
  availability_zone = data.aws_availability_zones.working.names[0]
  cidr_block        = "10.0.1.0/24" # we can use function to generate subnets
  tags = {
    Name    = "Subnet-1 in ${data.aws_availability_zones.working.names[0]}"
    Account = "Subnet in account: ${data.aws_caller_identity.current.account_id}"
    Region  = data.aws_region.current.name
  }
}

resource "aws_subnet" "prod_subnet_2" {
  vpc_id            = data.aws_vpc.my_vpc.id
  availability_zone = data.aws_availability_zones.working.names[1]
  cidr_block        = "10.0.2.0/24" # we can use function to generate subnets
  tags = {
    Name    = "Subnet-2 in ${data.aws_availability_zones.working.names[1]}"
    Account = "Subnet in account: ${data.aws_caller_identity.current.account_id}"
    Region  = data.aws_region.current.name
  }
}


output "data_aws_azs" {
  value = data.aws_availability_zones.working.names[1]
}

output "data_aws_caller_identity" {
  value = data.aws_caller_identity.current.account_id
}

output "data_aws_region" {
  value = data.aws_region.current.name
}
output "data_aws_region_description" {
  value = data.aws_region.current.description
}
output "data_aws_vpcs" {
  value = data.aws_vpcs.my_vpcs.ids
}

output "prod_vpc_id" {
  value = data.aws_vpc.my_vpc.id
}
output "prod_vpc_cidr" {
  value       = data.aws_vpc.my_vpc.cidr_block
  description = "Prod VPC CIDR"
}

