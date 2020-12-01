#-----------------------------------------------------------------
# My Teraform
# Build Webserver during Bootstrap
# 
# LyfeCycle Resources and Zero Down Time 
# opt 1 prevent_destroy = true
# opt 2 ignore_changes = [ami, user_data]
# opt 3 
# opt 3.1 attach elastic ip
# opt 3.2 when user_data is changed, new server it build and only after that old one is destoyed, reattach elastic ip
# ----------------------------------------------------------------

provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "la-sandbox"
}
resource "aws_eip" "EIP" {
  instance = aws_instance.my_webserver.id

}
resource "aws_instance" "my_webserver" {
  ami                    = "ami-04d29b6f966df1537" # Amazon Linux 2 in us-east-1
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  #key_name               = "Oregon"
  user_data = templatefile("user_data.sh.tpl", { f_name = "Walter", l_name = "Sobchak", names = ["Vasya", "Kolya", "Petya", "Vitya", "Katya"] }) #relative path
  tags = {
    Name  = "Lesson-6"
    Owner = "Walter Sobchak"
  }
  lifecycle {
    # prevent_destroy = true     # opt 1
    # ignore_changes = [ami]     # opt 2
    create_before_destroy = true # opt 3
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
