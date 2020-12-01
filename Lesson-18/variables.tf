variable "region" {
  description = "Please enter AWS Region to deploy server"
  type        = string
  default     = "us-east-1"
}
variable "aws_users" {
  description = "List of IAM users to create"
  default = [
    "Dude",
    "Walter",
    "Theodore",
    "Maude",
    "Jesus",
    "Bunny",
    "Brandt",
    "Jeffrey"
  ]
}



