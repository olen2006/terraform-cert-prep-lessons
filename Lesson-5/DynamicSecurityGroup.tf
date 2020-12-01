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
/* 
resource "aws_instance" "my_webserver" {
  ami                    = "ami-04d29b6f966df1537" # Amazon Linux 2 in us-east-1
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  #key_name               = "Oregon"
  user_data = templatefile("user_data.sh.tpl", { f_name = "Walter", l_name = "Sobchak", names = ["Vasya", "Kolya", "Petya"] }) #relative path
  tags = {
    Name  = "Lesson-5"
    Owner = "Walter Sobchak"
  }
}
 */
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
