provider "aws" {
  version = "~> 2.0"
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}
# create the VPC
resource "aws_vpc" "prd_vpc" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
tags = {
    Name = "prd_vpc"
}
}
# create the Subnet
resource "aws_subnet" "prd_pb_subnet" {
  vpc_id                  = aws_vpc.prd_vpc.id
  cidr_block              = element(var.subnetCIDRblock,count.index)
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = element(var.availabilityZone,count.index)
  count = length(var.subnetCIDRblock)
tags = {
   Name = "Subnet_${count.index +1}"
}
}
# Create the Security Group
resource "aws_security_group" "prd_security_grp" {
  vpc_id       = aws_vpc.prd_vpc.id
  name         = "prd_gw"
  description  = "prd_security_grp"

  # allow ingress of port 22 and 8080
  ingress {
    cidr_blocks = var.ingressCIDRblock
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = var.ingressCIDRblock
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
  }
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
   Name = "prd_security_grp"
   Description = "prd_security_grp"
}
}
# Create the Internet Gateway
resource "aws_internet_gateway" "prd_gw" {
 vpc_id = aws_vpc.prd_vpc.id
 tags = {
        Name = "prd_gw"
}
} # end resource
# Create the Route Table
resource "aws_route_table" "prd_rt" {
 vpc_id = aws_vpc.prd_vpc.id
 tags = {
        Name = "prd_rt"
}
}
# Create the Internet Access
resource "aws_route" "prd_internet_access" {
  route_table_id         = aws_route_table.prd_rt.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.prd_gw.id
}
# Associate the Route Table with the Subnet
resource "aws_route_table_association" "prd_rt_association" {
  count = length(var.subnetCIDRblock)
  subnet_id      = element(aws_subnet.prd_pb_subnet.*.id,count.index)
  route_table_id = aws_route_table.prd_rt.id
}
#creating application target
resource "aws_lb_target_group" "prd_tg" {
  name     = "prd-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.prd_vpc.id
  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 3
    path              = "/"
    interval            = 10
  }
}
#create security group for instance
resource "aws_security_group" "prd_alb_security_grp" {
  name = "terraform-alb"
  vpc_id       = aws_vpc.prd_vpc.id
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "prd_alb" {
  name               = "prd-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.prd_alb_security_grp.id]
  subnets            = aws_subnet.prd_pb_subnet.*.id

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.prd_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_tg.arn
  }
}

resource "aws_launch_configuration" "prd_launch_conf" {
  name_prefix   = "terraform-prd"
  image_id      = var.tomcat_ami
  instance_type = var.aws_instance_type
  security_groups = [aws_security_group.prd_security_grp.id]
  key_name = var.key_name

  lifecycle {
    create_before_destroy = true
  }
}

  resource "aws_autoscaling_group" "prd_asg" {
    launch_configuration = aws_launch_configuration.prd_launch_conf.id
    health_check_type         = "ELB"
    desired_capacity          = 2
    min_size = 1
    max_size = 5
    vpc_zone_identifier       = aws_subnet.prd_pb_subnet.*.id
    target_group_arns = [aws_lb_target_group.prd_tg.arn]
    tag {
      key = "Name"
      value = "prd_asg"
      propagate_at_launch = true
    }
  }
