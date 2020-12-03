provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "la-sandbox"
}
#-----Saving to dev/servers/terraform.tfstate--------------

# Remote state storing on S3
terraform {
  backend "s3" {
    bucket = "my-terraform-23102"            # Bucket where to SAVE Terraform State
    key    = "dev/servers/terraform.tfstate" # path to tfstate should be different from Layer-1-Network
    region = "us-east-1"                     # Region where bycket created
  }
}

#--Pulling data from dev/network/terraform.tfstate file----

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "my-terraform-23102"            # Bucket where to SAVE Terraform State
    key    = "dev/network/terraform.tfstate" # Object name in the bucket to SAVE Terraform State
    region = "us-east-1"
  }
}
#---------------------------------------------------------

data "aws_ami" "latest_amazon_linux_2" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # always get the latest version
  }
}

resource "aws_instance" "web-server" {
  ami                    = data.aws_ami.latest_amazon_linux_2.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.webserber-sg.id]
  subnet_id              = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  user_data              = <<EOF
#!/bin/bash
yum -y update 
yum -y install  httpd
myip =`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>Webserver with IP: $myip</h2><br>Build by Terraform with remote state" > /var/www/html/index.html
EC2_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
echo "<h2>$(hostname -f) in AZ $EC2_AVAIL_ZONE </h2>" >> /var/www/html/index.html
systemctl start httpd
systemctl enable httpd
EOF
  tags = {
    Name = "Webserver"
  }
}

resource "aws_security_group" "webserber-sg" {
  name   = "Webserver-SG"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = {
    Name  = "Webserver-SG"
    Owner = "Walter Sobchak"
  }
}

#---In case someone needs to use this data further--------
output "network_details" {
  value = data.terraform_remote_state.network
}

output "webserver_sg_id" {
  value = aws_security_group.webserber-sg.id
}

output "webserver_public_ip" {
  value = aws_instance.web-server.public_ip
}
