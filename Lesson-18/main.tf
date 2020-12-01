#----------------------------------------------------------
# My Terraform
#
# Terraform count, for and if
#
# 30.11.2020
#----------------------------------------------------------

provider "aws" {
  region                  = var.region #"us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "la-sandbox" # "la-sandbox"
}
/* 
resource "aws_iam_user" "user1" {
  name = "Pushkin"

} */
resource "aws_iam_user" "users" {
  count = length(var.aws_users)
  name  = element(var.aws_users, count.index)
}
#----------------------for-----------------
# Usecase: get cidr blocks for Security groups
# Generate list of sidr blocks first
output "created_iam_users_all" {
  value = aws_iam_user.users

}
output "created_iam_users_ids" {
  value = aws_iam_user.users[*].id # for all users
}
output "created_iam_users_custom" {
  value = [
    for user in aws_iam_user.users :
    "Username: ${user.name} has ARN ${user.arn}"
  ]
}
#----------------------map-----------------
output "created_iam_users_map" {
  value = {
    for user in aws_iam_user.users :
    user.unique_id => user.id # AIDAQRYS3OZNJEGWFE2PT : Brandt
  }

}
#----------------------if------------------
# Pring users with names less then 5 charachters ONLY
output "custom_if_length" {
  value = [
    for x in aws_iam_user.users :
    x.name
    if length(x.name) == 5
  ]
}
#---------------------count----------------
data "aws_ami" "latest_amazon_linux_2" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # always get the latest version
  }
}
resource "aws_instance" "servers" {
  count         = 3
  ami           = data.aws_ami.latest_amazon_linux_2.id
  instance_type = "t3.micro"
  tags = {
    Name = "Server Number - ${count.index + 1}"
  }
}
# Print map of EC2_ID : PublicIP
output "server_all" {
  value = {
    for server in aws_instance.servers :
    server.id => server.public_ip
  }
}
