variable "region" {
  description = "AWS Deployment region.."
  default = "us-east-1"
}
 #-----------VPC-------------------------

 variable "vpc_cidr" {
    description = "VPC Cidr range"
    default = "10.0.0.0/16"
 }

#--------------Subnets-----------------------


variable "public_availability_zone" {
  description = "availability zone for public subnet"
  type = string
  default = "us-east-1a"
}

variable "private_availability_zone" {
  description = "availability zone for public subnet"
  type = string
  default = "us-east-1b"
}

variable "public_cidr" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_cidr" {
  type = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "environment" {
  type = string
  default = "Preprod"
}

variable "tags" {
  type = map(string)
  default = {
    "env" = "testing"
  }
}

variable "public_inbound_acl_rules" {
  description = "Public subnets inbound network ACLs"
  type = list(object({
    rule_number             = number       
    rule_action             = string       
    from_port               = number      
    to_port                 = number      
    protocol                = string 
    cidr_block              = string 
  }))
  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "public_outbound_acl_rules" {
  description = "Public subnets outbound network ACLs"
  type = list(object({
    rule_number             = number       
    rule_action             = string       
    from_port               = number      
    to_port                 = number      
    protocol                = string 
    cidr_block              = string
  }))
  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "public_acl_tags" {
  description = "Additional tags for the public subnets network ACL"
  type        = map(string)
  default     = {}
}

#-----------private nacl

variable "private_inbound_acl_rules" {
  description = "Private subnets inbound network ACLs"
  type = list(object({
    rule_number             = number       
    rule_action             = string       
    from_port               = number      
    to_port                 = number      
    protocol                = string 
    cidr_block              = string
  }))
  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "private_outbound_acl_rules" {
  description = "Private subnets outbound network ACLs"
  type = list(object({
    rule_number             = number       
    rule_action             = string       
    from_port               = number      
    to_port                 = number      
    protocol                = string 
    cidr_block              = string
  }))
  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "private_acl_tags" {
  description = "Additional tags for the private subnets network ACL"
  type        = map(string)
  default     = {}
}

# ----------------------------------------
variable "lb_sg_rules" {
  description = "List of ingress rules to create by name"
  type = list(object({
    description             = string       
    type                    = string       
    from_port               = number      
    to_port                 = number      
    protocol                = string 
    cidr_blocks             = list(string) 
  }))
  default     = [
    {
      description     = "http"
      type            = "ingress" # "ingress or egress"
      cidr_blocks     = ["0.0.0.0/0"]
      protocol        = "tcp"
      from_port       = 80
      to_port         = 80
    },
  ]
}

variable "instance_sg_rules" {
  description = "List of ingress rules to create by name"
  type = list(object({
    description             = string       
    type                    = string       
    from_port               = number      
    to_port                 = number      
    protocol                = string 
    cidr_blocks             = list(string) 
  }))
  default     = [
    {
      description      = "ssh"
      type            = "ingress" # "ingress or egress"
      from_port        = 22
      to_port          = 22
      protocol         = "TCP"
      cidr_blocks      = ["specific ip address/32"] #or list of specific ip address 
    },
  ]
}


