##############################################################################
# count  https://www.terraform.io/docs/configuration/meta-arguments/count.html
#
##############################################################################
provider "aws" {
}

resource "aws_instance" "my_Ubuntu" {
  count         = 1
  ami           = "ami-07dd19a7900a1f049" # Ubuntu Server 20.04 LTS
  instance_type = "t2.micro"
  tags = {
    Name = "Ubuntu"
    Ver  = "20.04"
  }
}

resource "aws_instance" "my_AmazonLinux-2" {
  ami           = "ami-0e472933a1395e172" # Amazon Linux 2
  instance_type = "t3.micro"
  tags = {
    Name    = "AmazonLinux2"
    Project = "Lesson-1"
  }
}
