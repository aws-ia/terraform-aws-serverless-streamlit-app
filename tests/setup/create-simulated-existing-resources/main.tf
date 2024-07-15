# ################################################################################
# # VPC
# ################################################################################
# # Create VPC to host the ECS app
# resource "aws_vpc" "sample_existing_vpc" {
#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.app_name}-vpc"
#     }
#   )
# }

# # Create Subnets for the VPC
# # Public
# resource "aws_subnet" "sample_existing_public_subnet1" {
#   vpc_id = aws_vpc.sample_existing_vpc.id
#   # Create subnet that has
#   cidr_block        = cidrsubnet(aws_vpc.sample_existing_vpc.cidr_block, 8, 0)
#   availability_zone = data.aws_availability_zones.available.names[0] # first az
#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.app_name}-public-subnet1"
#     }
#   )
# }
# resource "aws_subnet" "sample_existing_public_subnet2" {
#   vpc_id            = aws_vpc.sample_existing_vpc.id
#   cidr_block        = cidrsubnet(aws_vpc.sample_existing_vpc.cidr_block, 8, 1)
#   availability_zone = data.aws_availability_zones.available.names[1] # second az
#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.app_name}-public-subnet2"
#     }
#   )
# }
# # Private
# resource "aws_subnet" "sample_existing_private_subnet1" {
#   vpc_id            = aws_vpc.sample_existing_vpc.id
#   cidr_block        = cidrsubnet(aws_vpc.sample_existing_vpc.cidr_block, 8, 2)
#   availability_zone = data.aws_availability_zones.available.names[0] # third az
#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.app_name}-private-subnet1"
#     }
#   )
# }
# resource "aws_subnet" "sample_existing_private_subnet2" {
#   vpc_id            = aws_vpc.sample_existing_vpc.id
#   cidr_block        = cidrsubnet(aws_vpc.sample_existing_vpc.cidr_block, 8, 3)
#   availability_zone = data.aws_availability_zones.available.names[1] # second az
#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.app_name}-private-subnet2"
#     }
#   )
# }

# # Create Internet Gateway
# resource "aws_internet_gateway" "sample_existing_igw" {
#   vpc_id = aws_vpc.sample_existing_vpc.id

#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.app_name}-igw"
#     }
#   )
# }

# # Create NAT Gateway
# resource "aws_nat_gateway" "sample_existing_ngw" {
#   allocation_id = aws_eip.sample_existing_eip.id
#   subnet_id     = aws_subnet.sample_existing_public_subnet1.id

#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.app_name}-ngw"
#     }
#   )

#   depends_on = [aws_internet_gateway.sample_existing_igw]
# }

# # Create Elastic IP Address
# resource "aws_eip" "sample_existing_eip" {
#   domain = "vpc"

#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.app_name}-eip"
#     }
#   )
# }


# # Create a route table for the VPC (Public Subnets)
# resource "aws_route_table" "sample_existing_route_table_public" {
#   vpc_id = aws_vpc.sample_existing_vpc.id

#   # Create route to IGW for all traffic that is not destined for local
#   # NOTE: Most specific route wins, so traffic destined for '10.0.0.0/16' is routed locally. All other traffic ('0.0.0.0/0') is routed to IGW.
#   route {
#     cidr_block = "0.0.0.0/0" # todo - make variable
#     gateway_id = aws_internet_gateway.sample_existing_igw.id
#   }
#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.app_name}-public-rt"
#     }
#   )
# }

# # Create a route table for the VPC (Private Subnets)
# resource "aws_route_table" "sample_existing_route_table_private" {
#   vpc_id = aws_vpc.sample_existing_vpc.id

#   # Create route to NAT GW for all traffic that is not destined for local
#   # NOTE: Most specific route wins, so traffic destined for '10.0.0.0/16' is routed locally. All other traffic ('0.0.0.0/0') is routed to IGW.
#   route {
#     cidr_block     = "0.0.0.0/0" # todo - make variable
#     nat_gateway_id = aws_nat_gateway.sample_existing_ngw.id
#   }


#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.app_name}-private-rt"
#     }
#   )
# }

# # Associate the public subnets with the route table and Internet Gateway
# resource "aws_route_table_association" "sample_existing_public_subnet1_association" {
#   subnet_id      = aws_subnet.sample_existing_public_subnet1.id
#   route_table_id = aws_route_table.sample_existing_route_table_public.id
# }
# resource "aws_route_table_association" "sample_existing_public_subnet2_association" {
#   subnet_id      = aws_subnet.sample_existing_public_subnet2.id
#   route_table_id = aws_route_table.sample_existing_route_table_public.id
# }

# # Associate the private subnets with the route table and NAT Gateway
# resource "aws_route_table_association" "sample_existing_private_subnet1_association" {
#   subnet_id      = aws_subnet.sample_existing_private_subnet1.id
#   route_table_id = aws_route_table.sample_existing_route_table_private.id
# }
# resource "aws_route_table_association" "private_subnet2_association" {
#   subnet_id      = aws_subnet.sample_existing_private_subnet2.id
#   route_table_id = aws_route_table.sample_existing_route_table_private.id
# }


# ################################################################################
# # Security Groups
# ################################################################################
# # Create security group for ECS
# resource "aws_security_group" "sample_existing_ecs_sg" {
#   name        = "${var.app_name}-ecs-sg"
#   vpc_id      = aws_vpc.sample_existing_vpc.id
#   description = "Security group for Streamlit ECS container."

#   ingress {
#     description = "Allow inbound traffic from ALB Security Group on port 8501 (Streamlit default port)."
#     from_port   = var.container_port
#     to_port     = var.container_port
#     protocol    = "tcp"

#     # Allow only the ALB SG to access the ECS Cluster via ECS Cluster SG
#     security_groups = [aws_security_group.sample_existing_lb_sg.id]

#   }

#   ingress {
#     description = "Allow inbound traffic from anywhere on port 443."
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"

#     # Allow all traffic to access the ALB (via CloudFront) since this is a public web app.
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     description = "Allow inbound traffic from anywhere on port 80."
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"

#     # Allow all traffic to access the ALB (via CloudFront) since this is a public web app.
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }


#   tags = {
#     Name = "${var.app_name}-ecs-sg"
#   }
# }

# # Create security group for ALB
# resource "aws_security_group" "sample_existing_lb_sg" {
#   name        = "${var.app_name}-alb-sg"
#   vpc_id      = aws_vpc.sample_existing_vpc.id
#   description = "Security group for Streamlit ALB."

#   ingress {
#     description = "Allow inbound traffic from anywhere on port 80."
#     from_port   = var.container_port
#     to_port     = var.container_port
#     protocol    = "tcp"

#     # Allow all traffic to access the ALB (via CloudFront) since this is a public web app.
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     description = "Allow inbound traffic from anywhere on port 443."
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"

#     # Allow all traffic to access the ALB (via CloudFront) since this is a public web app.
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     description = "Allow inbound traffic from anywhere on port 80."
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"

#     # Allow all traffic to access the ALB (via CloudFront) since this is a public web app.
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.app_name}-alb-sg"
#   }
# }
