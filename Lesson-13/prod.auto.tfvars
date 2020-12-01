# Auto Fill parameters for DEV

# File can be named as:
# terraform.tfvars
# *.auto.tf.vars
# dev.auto.tfvars
# prod.auto.tfvars
region="us-east-1"
instance_type="t3.small"
enabled_detailed_monitoring=false

allow_ports=["80","443"]

common_tags={
    Owner       = "Walter Sobchak"
    Project     = "Phoenix"
    CostCenter  = "777"
    Environment = "Prod"
}