#-----------------------------------------------------------------
# My Teraform
# Build Webserver during Bootstrap
# 
# Create server web, app, dSobchak 
# Order of creation: db, app, web
#
# ----------------------------------------------------------------

provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "la-sandbox"
}
resource "aws_eip" "EIP" {
  instance = aws_instance.my_server_weSobchakid

}
resource "aws_instance" "my_server_web" {
  ami                    = "ami-04d29b6f966df1537" # Amazon Linux 2 in us-east-1
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  tags = {
    Lesson = "8"
    Server = "Server-Web"
  }
  depends_on = [aws_instance.my_server_db, aws_instance.my_server_app] # depends on two servers
}

resource "aws_instance" "my_server_app" {
  ami                    = "ami-04d29b6f966df1537" # Amazon Linux 2 in us-east-1
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  tags = {
    Lesson = "8"
    Name   = "Server-App"
  }
  depends_on = [aws_instance.my_server_db]
}

resource "aws_instance" "my_server_db" {
  ami                    = "ami-04d29b6f966df1537" # Amazon Linux 2 in us-east-1
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  tags = {
    Lesson = "8"
    Name   = "Server-Database"
  }
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
