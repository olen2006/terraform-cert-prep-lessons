

provider "aws" {
  region                  = var.region #"us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "la-sandbox" # "la-sandbox"
}
## Getting latest AMI
data "aws_ami" "latest_amazon_linux_2" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # always get the latest version
  }
}
## Elastic IP
resource "aws_eip" "my_static_ip" {
  instance = aws_instance.my_server.id
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]}-Server IP" }) # ls
  /*   tags = {
    Name    = "Server IP"
    Owner   = "Denis Astahov"
    Project = "Phoenix"
  } */

}

## EC2 Server
resource "aws_instance" "my_server" {
  ami                    = data.aws_ami.latest_amazon_linux_2.id
  instance_type          = var.instance_type #"t3.micro"
  vpc_security_group_ids = [aws_security_group.my_server.id]
  monitoring             = var.enabled_detailed_monitoring #
  tags                   = merge(var.common_tags, { Name = "${var.common_tags["Environment"]}-Server  build by Terraform" }, { Region = var.region })
  /*   tags = {
    Name    = "Server  build by Terraform"
    Owner   = "Denis Astahov"
    Project = "Phoenix"
    Region  = var.region
  } */
}

resource "aws_security_group" "my_server" {
  name        = "Server-SG"
  description = "My Security Group"
  dynamic "ingress" {
    for_each = var.allow_ports #["80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # can be in variables.tf as well
    }
  }
  egress {

    description = "SSH Access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]}-Server Security Group" })
  /*   tags = {
    Name    = "Server Security Group"
    Owner   = "Denis Astahov"
    Project = "Phoenix"
  } */
}
