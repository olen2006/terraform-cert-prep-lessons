#-----------------------------------------------------------------
# My Teraform
# Build Webserver during Bootstrap
# 28.11.2020
#
# instance  with user_data + Simple SG 
# ----------------------------------------------------------------

provider "aws" {
  region = "us-west-2"
}
resource "aws_instance" "my_webserver" {
  ami                    = "ami-0e472933a1395e172" # Amazon Linux 2
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  key_name               = "Oregon"
  user_data              = <<EOF
#!/bin/bash
yum -y update 
yum -y install  httpd
#myip =`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>Webserver with IP: $(ec2-metadata -o | cut -d " " -f 2)</h2><br>Build by Terraform" > /var/www/html/index.html
EC2_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
echo "<h2>$(hostname -f) in AZ $EC2_AVAIL_ZONE </h2>" >> /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd
EOF
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
