#-----------------------------------------------------------------
# My Teraform
# Build Webserver during Bootstrap
# 28.11.2020
# Lesson-5
# Creating Dynamic rules for SG
# ----------------------------------------------------------------

provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "la-sandbox"
}
resource "aws_security_group" "my_webserver" {
  name        = "Dynamic-SG"
  description = "Dynamic Security Group"

  dynamic "ingress" {
    for_each = ["80", "443", "8080"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["66.222.167.242/32"]
    description = "My Public IPV4"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Dynamic Security Group"
    Owner = "Walter Sobchak"
  }
}
