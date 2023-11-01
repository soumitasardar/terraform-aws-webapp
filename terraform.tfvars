region = "us-east-1"
vpc_cidr = "10.0.0.0/16"

# for subnet details
public_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
public_availability_zone = "us-east-1a"

private_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
private_availability_zone = "us-east-1b"

# public Nacl inputs---------------------
public_inbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
    #   cidr_block  = ["0.0.0.0/0"]# required set of ip cidr or address who should be accessible for eweb apps
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 120
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
    #   cidr_block  = ["0.0.0.0/0"]# required set of ip cidr or address who should be accessible for eweb apps
      cidr_block  = "0.0.0.0/0"
    },
]

public_acl_tags = {
    env = "test"
}

public_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"# required set of ip cidr or address who should be accessible for eweb apps
    },
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"# required set of ip cidr or address who should be accessible for eweb apps
    },
]

# Private nacl--------------------------
private_inbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "" #"<ALB source IP or range>" # required set of ip cidr or address who should be accessible for eweb app
    },
    {
      rule_number = 120
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = "" #"<ALB source IP or range>" # required set of ip cidr or address who should be accessible for eweb app
    },
]


# security group -----------------------------------
lb_sg_rules = [
    {
        description      = "https_rule"
        type             = "ingress"
        from_port        = 443
        to_port          = 443
        protocol         = "TCP"
        cidr_blocks      = ["0.0.0.0/0"] #or specific cidr of ip address if end users are specific 
    },
    {
        description      = "http_rule"
        type             = "ingress"
        from_port        = 80
        to_port          = 80
        protocol         = "TCP"
        cidr_blocks      = ["0.0.0.0/0"] #or specific cidr of ip address if end users are specific
    },
    {
        description      = "https_rule"
        type             = "egress"
        from_port        = 443
        to_port          = 443
        protocol         = "TCP"
        cidr_blocks      = ["0.0.0.0/0"] #or specific cidr of ip address if end users are specific 
    },
    {
        description      = "http_rule"
        type             = "egress"
        from_port        = 80
        to_port          = 80
        protocol         = "TCP"
        cidr_blocks      = ["0.0.0.0/0"] #or specific cidr of ip address if end users are specific
    },
]

instance_sg_rules = [
    {
      description      = "ssh"
      type            = "ingress" # "ingress or egress"
      from_port        = 22
      to_port          = 22
      protocol         = "TCP"
      cidr_blocks      = ["10.0.3.0/24"] #or list of specific ip address 
    },
    {
      description      = "allow_all"
      type            = "egress" # "ingress or egress"
      from_port        = 0
      to_port          = 65535
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"] #or list of specific ip address 
    },
]