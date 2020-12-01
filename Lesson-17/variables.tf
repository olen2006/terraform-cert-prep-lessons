variable "region" {
  description = "Please enter AWS Region to deploy server"
  type        = string
  default     = "us-east-1"
}
variable "env" {
  default = "prod"

}
## lookup example
variable "ec2_size" {
  default = {
    "prod"    = "t3.medium"
    "staging" = "t3.small"
    "dev"     = "t3.micro"
  }
}
variable "allow_port_list" {
  default = {
    "prod"    = ["80"]
    "staging" = ["8080", "22"]
    "dev"     = ["80", "443", "8080", "22"]
  }

}
variable "prod_owner" {
  default = "Walter Sobchak"
}

variable "noprod_owner" {
  default = "Kolya Mineralka"
}
