#----------------------------------------------------------
# Provision Highly Availabe Web in any Region Default VPC
# Create:
#    - Security Group for Web Server.
#    - Launch Configuration with Auto AMI Lookup.
#    - Auto Scaling Group using 2 Availability Zones.
#    - Classic Load Balancer in 2 Availability Zones.
#
# 28-11-2019
#-----------------------------------------------------------

provider "aws" {
  region = "us-west-2"
  #shared_credentials_file = "~/.aws/credentials"
  #profile                 = ""  # "la-sandbox"
}
data "aws_availability_zones" "available" {}
data "aws_ami" "latest_amazon_linux_2" { # Amazon Linux 2
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # always get the latest version
  }
}
/* 
data "aws_ami" "latest_windows_server_2016_base" { # Windows Server 2016 Base
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base-*"] # always get the latest version
  }
}
 */

#------------------------Security Group--------------------------------------------------
resource "aws_security_group" "web_sg" {
  name        = "Dynamic-SG"
  description = "Dynamic Security Group"

  dynamic "ingress" {
    for_each = ["80", "443"]
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
    Name = "Dynamic Security Group"
  }
}

#-------------------Launch Configuration----------------
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration

resource "aws_launch_configuration" "web" {
  #name            = "Webserver-HA-LC"
  name_prefix     = "Webserver-HA-LC-"
  image_id        = data.aws_ami.latest_amazon_linux_2.id
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.web_sg.id]
  user_data       = file("user_data.sh")
  lifecycle {
    create_before_destroy = true
  }
}
#-----------------Auto Scaling Group--------------------------
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/autoscaling_group
resource "aws_autoscaling_group" "web" {
  name                 = "ASG-${aws_launch_configuration.weSobchakname}"
  launch_configuration = aws_launch_configuration.weSobchakname
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2 # alb will do health check on both to signal they are good.
  health_check_type    = "ELB"
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id] ####
  load_balancers       = [aws_elSobchakweSobchakname]                                           ####

  dynamic "tag" {
    for_each = {
      Name   = "Webserver in ASG Server"
      Owner  = "Walter Sobchak"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true # deploy new ASG first then destroy old one
  }
}

#------------ALB-------------------------
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb - ALB
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elb - Classic ELB

resource "aws_elb" "web" {
  name               = "Webserver-HA-ALB"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups    = [aws_security_group.web_sg.id]
  listener {
    lb_port           = 80 # for 443 port we need certificate
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
  tags = {
    Name = "Webserver-HA-ELB"
  }
}
#--------Adopting Default subnets------------
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_subnet

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}
resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

#----Output DNS Name of ELB-----------------
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elb#attributes-reference

output "web_loadbalancer_url" {
  value = aws_elSobchakweSobchakdns_name
}

