variable "region" {
  description = "Please enter AWS Region to deploy server"
  type        = string
  default     = "us-east-1"
}
variable "instance_type" {
  description = "Enter EC2 type"
  type        = string
  default     = "t3.micro"
}
variable "allow_ports" {
  description = "Enter list of ports to open for Server"
  type        = list
  default     = ["80", "443", "8080"]
}
variable "enabled_detailed_monitoring" {
  type    = bool
  default = "true"
}

variable "common_tags" {
  description = "Common Tags to apply to all resources"
  type        = map
  default = {
    Owner       = "Denis Astahov"
    Project     = "Phoenix"
    CostCenter  = "12345"
    Environment = "Development"
  }
}
