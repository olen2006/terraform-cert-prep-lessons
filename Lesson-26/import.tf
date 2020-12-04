resource "aws_instance" "node1"{
    ami="ami-04d29b6f966df1537"
    instance_type="t2.micro"
    tags={
        Name="New"
        Owner="Walter"
    }
}

resource "aws_security_group" "nomad"{
    name                   = "launch-wizard-1"
    description            = "launch-wizard-1 created 2020-12-04T01:52:59.312-07:00"
    tags={
        Name="New"
        Owner="Walter"
    }
}