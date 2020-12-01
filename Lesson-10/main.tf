provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "la-sandbox"
}

data "aws_ami" "latest_ubuntu" { # Ubuntu Server 20.04 LTS
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] # always get the latest version
  }
}

data "aws_ami" "latest_amazon_linux_2" { # Amazon Linux 2
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # always get the latest version
  }
}

data "aws_ami" "latest_windows_server_2016_base" { # Windows Server 2016 Base
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base-*"] # always get the latest version
  }
}

resource "aws_instance" "my_webserver_ubuntu" {
  ami           = data.aws_ami.latest_ubuntu.id # Now latest version will be always deployed on a server
  instance_type = "t3.micro"

}

output "latest_ubuntu_ami_id" { value = data.aws_ami.latest_ubuntu.id }
output "latest_ubuntu_ami_name" { value = data.aws_ami.latest_ubuntu.name }
output "latest_amazon_linux_2_id" { value = data.aws_ami.latest_amazon_linux_2.id }
output "latest_amazon_linux_2_name" { value = data.aws_ami.latest_amazon_linux_2.name }
output "latest_windows_server_2016_base_id" { value = data.aws_ami.latest_windows_server_2016_base.id }
output "latest_windows_server_2016_base_name" { value = data.aws_ami.latest_windows_server_2016_base.name }

