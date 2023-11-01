
################################################

#terraform 0.13 or later...
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
}

#to control routing independently for each type of subnet.
/*   Route Table for public */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}
/*   Route Table for peivate */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

/* Public Subnet*/
resource "aws_subnet" "public_subnet" {
  count = length(var.public_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_cidr[count.index]
  availability_zone       = var.public_availability_zone
  map_public_ip_on_launch = true
  tags = merge(
    {Name = "public subnet"},
    var.tags
  )
}

/*  Private Subnet */
resource "aws_subnet" "private" {
  count = length(var.private_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_cidr[count.index]
  availability_zone       = var.private_availability_zone
  map_public_ip_on_launch = false
  tags = merge(
    {Name = "private subnet"},
    var.tags
  )
}

/*   Route table association*/
resource "aws_route_table_association" "public" {
  count = length(var.public_cidr)

  subnet_id      = "${element(aws_subnet.public_subnet[*].id, count.index)}"
  route_table_id = aws_route_table.public.id
}

/*   Route table association*/
resource "aws_route_table_association" "private" {
  count = length(var.private_cidr)

  subnet_id      = "${element(aws_subnet.private[*].id, count.index)}"
  route_table_id = aws_route_table.private.id
}

# ---------------------------------------------------------------------------------------------------------------
/*  Nacl creation  public*/
resource "aws_network_acl" "public" {

  vpc_id = aws_vpc.main.id
  subnet_ids = aws_subnet.public_subnet[*].id

  tags = merge(
    { "Name" = "public nacl" },
    var.public_acl_tags
  )
}

# nacl public inbound rule
resource "aws_network_acl_rule" "public_inbound" {
  count = length(var.public_inbound_acl_rules)

  network_acl_id = aws_network_acl.public.id

  egress          = false
  rule_number     = var.public_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.public_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.public_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.public_inbound_acl_rules[count.index], "to_port", null)
  protocol        = var.public_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.public_inbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_network_acl_rule" "public_outbound" {
  count = length(var.public_outbound_acl_rules)

  network_acl_id = aws_network_acl.public.id

  egress          = true
  rule_number     = var.public_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.public_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.public_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.public_outbound_acl_rules[count.index], "to_port", null)
  protocol        = var.public_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.public_outbound_acl_rules[count.index], "cidr_block", null)
}


/*  Nacl  Association*/
resource "aws_network_acl_association" "public" {
  count = length(var.public_cidr)
  network_acl_id = aws_network_acl.public.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

# --------------------------------------------------------------------------------------------------------
/*  Nacl creation private */
resource "aws_network_acl" "private" {

  vpc_id = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  tags = merge(
    { "Name" = "private nacl" },
    var.private_acl_tags
  )
}

resource "aws_network_acl_rule" "private_inbound" {
  count = length(var.private_inbound_acl_rules)

  network_acl_id = aws_network_acl.private.id

  egress          = false
  rule_number     = var.private_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_inbound_acl_rules[count.index], "to_port", null)
  protocol        = var.private_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_inbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_network_acl_rule" "private_outbound" {
  count = length(var.private_outbound_acl_rules)

  network_acl_id = aws_network_acl.private.id

  egress          = true
  rule_number     = var.private_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_outbound_acl_rules[count.index], "to_port", null)
  protocol        = var.private_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_outbound_acl_rules[count.index], "cidr_block", null)
}

/*  Nacl  Association private*/
resource "aws_network_acl_association" "private" {
  count = length(var.private_cidr)
  network_acl_id = aws_network_acl.private.id
  subnet_id      = aws_subnet.private[count.index].id
}

# --------------------------------------------------------------------------------------------------
/*Internet Gateway to control routing independently for each type of subnet*/

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}


# ------------------------------------------------------------------------------------
/*Nat gateway to allow instance in private subnet to communicate in internet */

resource "aws_eip" "nat_gateway" {
  count = length(var.private_cidr) # Set this to the number of NAT Gateways you want to create
}

resource "aws_nat_gateway" "ng" {
  count = length(var.private_cidr)
  allocation_id  = "${element(aws_eip.nat_gateway.*.id, count.index)}"
  subnet_id    = "${element(aws_subnet.public_subnet.*.id, count.index)}"
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ng[0].id
}


# --------------------------------------------------------------------------------------------------
/*    Security group for LB   */
resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  description = "security group for LB"
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      "Name" = "lb_sg"
    },
    var.tags,
  )
}

# Security group rules with "cidr_blocks" and it uses list of rules names
resource "aws_security_group_rule" "lb_sg_rules" {
  count = length(var.lb_sg_rules)
  security_group_id = aws_security_group.lb_sg.id
  type              = lookup(var.lb_sg_rules[count.index], "type", null)
  description       =  lookup(var.lb_sg_rules[count.index], "description", null)
  cidr_blocks       = lookup(var.lb_sg_rules[count.index], "cidr_blocks", null)
  protocol          = lookup(var.lb_sg_rules[count.index], "protocol", null)
  from_port         = lookup(var.lb_sg_rules[count.index], "from_port", null)
  to_port           = lookup(var.lb_sg_rules[count.index], "to_port", null)
}



/*    Security group for Underline Instance   */
resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "security group for Underline Instance"

  tags = merge(
    {
      "Name" = "instance_sg"
    },
    var.tags,
  )
}

resource "aws_security_group_rule" "instance_sg_rules" {
  count = length(var.instance_sg_rules)
  security_group_id = aws_security_group.instance_sg.id
  type              = lookup(var.instance_sg_rules[count.index], "type", null)
  description       =  lookup(var.instance_sg_rules[count.index], "description", null)
  cidr_blocks       = lookup(var.instance_sg_rules[count.index], "cidr_blocks", null)
  protocol          = lookup(var.instance_sg_rules[count.index], "protocol", null)
  from_port         = lookup(var.instance_sg_rules[count.index], "from_port", null)
  to_port           = lookup(var.instance_sg_rules[count.index], "to_port", null)
}

# ----------------------------------------------------------------
/*   Application load balancer */
resource "aws_lb" "test_lb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_subnet[*].id]

  enable_deletion_protection = true


  tags = {
    Environment = "test"
  }
}

/* LB Target group*/
resource "aws_lb_target_group" "test_lb_tg" {
  name     = "test-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"

  health_check {
    path = "/"
    protocol = "HTTP"
    port = "80"
    healthy_threshold  = 2
    unhealthy_threshold = 2
    timeout  = 5
    interval = 30
  }
}

/*LB Listner*/
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.test_lb.arn}"
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.test_lb_tg.arn}"
  }
}

/* Attach the target group with load balancer */
resource "aws_lb_target_group_attachment" "web_app" {
  target_group_arn = aws_lb_target_group.test_lb_tg.arn
  target_id = aws_autoscaling_group.web_app_asg.id
}

# ----------------------------------
# getting latest ami image for amzon linux
data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}


/* ASG creation for web application*/
resource "aws_launch_configuration" "web_app_lc" {
  name_prefix         = "webapp-launch-config-"
  image_id            = data.aws_ami.latest_amazon_linux.id  # Use the latest AWS AMI (update "latest" to your desired criteria)

  instance_type       = "t2.micro"  # Customize instance type
  key_name            = "webapp-key-pair"
  security_groups     = [aws_security_group.instance_sg.id]
  # Attach the root volume with the desired size (e.g., 20 GB).
  root_block_device {
    volume_size       = 20
  }

  # Attach a secondary volume for log data with a desired size (e.g., 50 GB).
  ebs_block_device {
    device_name       = "/dev/sdf"
    volume_size       = 50
    volume_type       = "gp2"  # Customize volume type
  }

  user_data           = file("./web-application.sh")

}

resource "aws_autoscaling_group" "web_app_asg" {
  name_prefix = "web-app-asg-"
  desired_capacity   = 2
  max_size           = 10
  min_size           = 2
  vpc_zone_identifier  = [aws_subnet.private[*].id]
  health_check_type = "EC2"
  #health_check_grace_period = 300 # default is 300 seconds  
  launch_configuration = aws_launch_configuration.web_app_lc.name
  tag {
    key                 = "Owners"
    value               = "Web-Team"
    propagate_at_launch = true
  }      
}

