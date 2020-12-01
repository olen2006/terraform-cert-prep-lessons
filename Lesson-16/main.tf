#-----------------------------------------------
# 11-21 Generating, storing,using passwords
# Useful Resources
# https://blog.gruntwork.io/a-comprehensive-guide-to-managing-secrets-in-your-terraform-code-1d586955ace1
# https://www.terraform.io/docs/state/sensitive-data.html
#-----------------------------------------------

provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "la-sandbox"
}
variable "name" {
  default = "kolya" # rds password change

}
resource "random_string" "rds_password" {
  length           = 12
  special          = true
  override_special = "!#$&" # RDS can allow only certain sp characters
  keepers = {
    keeper_pass_change = var.name
  }
}
resource "aws_ssm_parameter" "rds_password" {
  name        = "/prod/mysql"
  description = "Master Password for RDS MySQL"
  type        = "SecureString"
  value       = random_string.rds_password.result # "mypassword#!"
}

data "aws_ssm_parameter" "my_rds_password" {
  name       = "/prod/mysql"
  depends_on = [aws_ssm_parameter.rds_password] #!
}

resource "aws_db_instance" "default" {
  identifier           = "prod-rds" # Name of the RDS instance
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "dSobchakt2.micro"
  name                 = "prod" #DB name
  username             = "administrator"
  password             = data.aws_ssm_parameter.my_rds_password.value
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true # don't make snapshots prior delition
  apply_immediately    = true # apply db changes right away 
}
output "rds_password" {
  value = data.aws_ssm_parameter.my_rds_password.value

}
