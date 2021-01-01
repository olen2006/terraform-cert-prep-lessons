#-----------------------------------------------------------------
# My Teraform
# Build Webserver during Bootstrap
# 28.11.2020
# templatefile function, working with variable
# ----------------------------------------------------------------

provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "la-sandbox"
}
resource "aws_instance" "my_webserver" {
  ami                    = "ami-04d29b6f966df1537" # Amazon Linux 2 in us-east-1
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  #key_name               = "Oregon"
  user_data = templatefile("user_data.sh.tpl", { f_name = "Walter", l_name = "Sobchak", names = ["Vasya", "Kolya", "Petya"] }) #relative path


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
