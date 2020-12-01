provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "la-sandbox"
}
data "aws_ami" "latest_amazon_linux_2" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # always get the latest version
  }
}

resource "null_resource" "command1" {
  provisioner "local-exec" {
    command = "echo Terraoform START: $(date) >> log.txt"
  }
}
resource "null_resource" "command2" {
  provisioner "local-exec" {
    #command = "ping -c 5 www.google.com"
    #command="python -c 'print('HelloWorld')'"
    command     = "print('Hello World!')"
    interpreter = ["python3", "-c"]
  }
  #depends_on = [null_resource.command1]
}

resource "null_resource" "command3" {
  provisioner "local-exec" {
    command = " echo $Name1 $Name2 $Name3 >> names.txt"
    environment = {
      Name1 = "Vasya"
      Name2 = "Kolya"
      Name3 = "Petya"
    }
  }
}

resource "aws_instance" "my_server" {
  ami           = data.aws_ami.latest_amazon_linux_2.id
  instance_type = "t2.micro"
  #for example we need to ping resource before deployment
  provisioner "local-exec" {
    command = "echo Hello from AWS instance creation!"

  }
}

resource "null_resource" "command5" {
  provisioner "local-exec" {
    command = "echo Terraoform END: $(date) >> log.txt"
  }
  depends_on = [null_resource.command1, null_resource.command2, null_resource.command3, aws_instance.my_server]
}
