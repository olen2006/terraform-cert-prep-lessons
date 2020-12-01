# Auto Fill parameters for DEV

# File can be named as:
# terraform.tfvars
# *.auto.tf.vars
# dev.auto.tfvars
# prod.auto.tfvars
region="us-west-2"
instance_type="t2.micro"
enabled_detailed_monitoring=false

allow_ports=["80","443", "22","443"]

common_tags={
    Owner       = "Walter Sobchak"
    Project     = "Phoenix"
    CostCenter  = "12345"
    Environment = "Dev"
}