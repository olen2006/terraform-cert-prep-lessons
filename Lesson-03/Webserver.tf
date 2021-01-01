##################################################################
# My Teraform
# Build Webserver during Bootstrap
# 29.11.2020
# file function  file("user_data.sh")
##################################################################

provider "aws" {
  region = "us-west-2"
}
resource "aws_instance" "my_webserver" {
  ami                    = "ami-0e472933a1395e172" # Amazon Linux 2
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  key_name               = "Oregon"
  user_data              = file("user_data.sh") #relative path


  tags = {
    Name  = "Webserver build by Terraform"
    Owner = "Walter Sobchak"
  }
}

resource "aws_security_group" "my_webserver" {
  name        = "Webserver Security Group"
  description = "My first SG"
  # It will use default vc in this case
  #vpc_id      = aws_vpc.main.id 

  ingress {
    description = "HTTP Traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #[aws_vpc.main.cidr_block]
  }
  ingress {
    description = "HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Webserver Security Group"
    Owner = "Walter Sobchak"
  }
}
