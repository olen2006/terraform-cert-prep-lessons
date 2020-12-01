#----------------------------------------------------------
# My Terraform
#
# Provision Resources in Multiply AWS Regions / Accounts
#
# 30.11.2020
#----------------------------------------------------------
provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "la-sandbox" # "la-sandbox"
  # to deploy in another account using cross account access 
  # opt 1  using keys
  #   access_key = "value"
  #   secret_key = "value"
  #   # opt 2 assuming role
  #   assume_role {
  #     #https://youtu.be/9QRUaGP_NnI
  #     role_arn     = "arn:aws:iam::1234567890:role/RemoteAdministrators"
  #     session_name = "Terraform_Walter"
  #   }
}
# default creds will be used 
provider "aws" {
  region = "us-west-2"
  alias  = "USA"

}
provider "aws" {
  region = "eu-central-1"
  alias  = "GER"

}
#------------------------------------------------
data "aws_ami" "defaut_latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "aws_ami" "usa_latest_ubuntu" {
  provider    = aws.USA
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "aws_ami" "ger_latest_ubuntu" {
  provider    = aws.GER
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}
#-------------------------------------------------------------

resource "aws_instance" "my_default_server" {
  instance_type = "t3.micro"
  ami           = data.aws_ami.defaut_latest_ubuntu.id
  tags = {
    Name = "Default Server"
  }
}

resource "aws_instance" "my_usa_server" {
  provider      = aws.USA
  instance_type = "t3.micro"
  ami           = data.aws_ami.usa_latest_ubuntu.id
  tags = {
    Name = "USA Server"
  }
}

resource "aws_instance" "my_ger_server" {
  provider      = aws.GER
  instance_type = "t3.micro"
  ami           = data.aws_ami.ger_latest_ubuntu.id
  tags = {
    Name = "GERMANY Server"
  }
}

