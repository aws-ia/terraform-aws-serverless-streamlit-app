################################################################################
# hashicorp/random
################################################################################
# - Random Strings to prevent naming conflicts -
resource "random_string" "streamlit_s3_bucket" {
  length  = 4
  special = false
  upper   = false
}

################################################################################
# VPC
################################################################################
# Create VPC to host the ECS app
resource "aws_vpc" "streamlit_vpc" {
  count = var.create_vpc_resources ? 1 : 0

  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-vpc"
    }
  )
}

# Create Subnets for the VPC
# Public
resource "aws_subnet" "public_subnet1" {
  count = var.create_vpc_resources ? 1 : 0

  vpc_id            = aws_vpc.streamlit_vpc[0].id
  cidr_block        = cidrsubnet(aws_vpc.streamlit_vpc[0].cidr_block, 8, 0)
  availability_zone = data.aws_availability_zones.available.names[0] # first az

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-public-subnet1"
    }
  )
}
resource "aws_subnet" "public_subnet2" {
  count = var.create_vpc_resources ? 1 : 0

  vpc_id            = aws_vpc.streamlit_vpc[0].id
  cidr_block        = cidrsubnet(aws_vpc.streamlit_vpc[0].cidr_block, 8, 1)
  availability_zone = data.aws_availability_zones.available.names[1] # second az

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-public-subnet2"
    }
  )
}
# Private
resource "aws_subnet" "private_subnet1" {
  count = var.create_vpc_resources ? 1 : 0

  vpc_id            = aws_vpc.streamlit_vpc[0].id
  cidr_block        = cidrsubnet(aws_vpc.streamlit_vpc[0].cidr_block, 8, 2)
  availability_zone = data.aws_availability_zones.available.names[0] # first az

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-private-subnet1"
    }
  )
}
resource "aws_subnet" "private_subnet2" {
  count = var.create_vpc_resources ? 1 : 0

  vpc_id            = aws_vpc.streamlit_vpc[0].id
  cidr_block        = cidrsubnet(aws_vpc.streamlit_vpc[0].cidr_block, 8, 3)
  availability_zone = data.aws_availability_zones.available.names[1] # second az

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-private-subnet2"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "streamlit_igw" {
  count = var.create_vpc_resources ? 1 : 0

  vpc_id = aws_vpc.streamlit_vpc[0].id

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-igw"
    }
  )
}

# Create NAT Gateway
resource "aws_nat_gateway" "streamlit_ngw" {
  count = var.create_vpc_resources ? 1 : 0

  allocation_id = aws_eip.streamlit_eip[0].id
  subnet_id     = aws_subnet.public_subnet1[0].id

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-ngw"
    }
  )

  depends_on = [aws_internet_gateway.streamlit_igw[0]]
}

# Create Elastic IP Address
resource "aws_eip" "streamlit_eip" {
  count = var.create_vpc_resources ? 1 : 0

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-eip"
    }
  )
}

# Create a route table for the VPC (Public Subnets)
resource "aws_route_table" "streamlit_route_table_public" {
  count = var.create_vpc_resources ? 1 : 0

  vpc_id = aws_vpc.streamlit_vpc[0].id

  # Create route to IGW for all traffic that is not destined for local
  # NOTE: Most specific route wins, so traffic destined for '10.0.0.0/16' is routed locally. All other traffic ('0.0.0.0/0') is routed to IGW.
  route {
    cidr_block = "0.0.0.0/0" # todo - make variable
    gateway_id = aws_internet_gateway.streamlit_igw[0].id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-public-rt"
    }
  )
}

# Create a route table for the VPC (Private Subnets)
resource "aws_route_table" "streamlit_route_table_private" {
  count = var.create_vpc_resources ? 1 : 0

  vpc_id = aws_vpc.streamlit_vpc[0].id

  # Create route to NAT GW for all traffic that is not destined for local
  # NOTE: Most specific route wins, so traffic destined for '10.0.0.0/16' is routed locally. All other traffic ('0.0.0.0/0') is routed to IGW.
  route {
    cidr_block     = "0.0.0.0/0" # todo - make variable
    nat_gateway_id = aws_nat_gateway.streamlit_ngw[0].id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-private-rt"
    }
  )
}

# Associate the public subnets with the route table and Internet Gateway
resource "aws_route_table_association" "public_subnet1_association" {
  count = var.create_vpc_resources ? 1 : 0

  subnet_id      = aws_subnet.public_subnet1[0].id
  route_table_id = aws_route_table.streamlit_route_table_public[0].id
}
resource "aws_route_table_association" "public_subnet2_association" {
  subnet_id      = aws_subnet.public_subnet2[0].id
  route_table_id = aws_route_table.streamlit_route_table_public[0].id
}

# Associate the private subnets with the route table and NAT Gateway
resource "aws_route_table_association" "private_subnet1_association" {
  subnet_id      = aws_subnet.private_subnet1[0].id
  route_table_id = aws_route_table.streamlit_route_table_private[0].id
}
resource "aws_route_table_association" "private_subnet2_association" {
  subnet_id      = aws_subnet.private_subnet2[0].id
  route_table_id = aws_route_table.streamlit_route_table_private[0].id
}


################################################################################
# Security Groups
################################################################################
# Create security group for ECS
resource "aws_security_group" "streamlit_ecs_sg" {
  count = var.create_ecs_security_group ? 1 : 0

  name        = "${var.app_name}-ecs-sg"
  vpc_id      = aws_vpc.streamlit_vpc[0].id
  description = "Security group for Streamlit ECS container."

  tags = {
    Name = "${var.app_name}-ecs-sg"
  }
}
# ECS Security Group Rules
# Ingress
resource "aws_vpc_security_group_ingress_rule" "streamlit_ecs_sg_alb_traffic" {
  count = var.create_ecs_security_group ? 1 : 0

  security_group_id            = aws_security_group.streamlit_ecs_sg[0].id
  referenced_security_group_id = aws_security_group.streamlit_alb_sg[0].id
  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
  description                  = "Allow inbound traffic from ALB Security Group on port 8501 (Streamlit default port)."

  tags = {
    SecurityGroup = "${var.app_name}-ecs-sg"
  }
}
resource "aws_vpc_security_group_ingress_rule" "streamlit_ecs_sg_http_traffic" {
  count = var.create_ecs_security_group ? 1 : 0

  security_group_id            = aws_security_group.streamlit_ecs_sg[0].id
  referenced_security_group_id = aws_security_group.streamlit_alb_sg[0].id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "Allow inbound traffic from ALB Security Group on port 80 (HTTP)."

  tags = {
    SecurityGroup = "${var.app_name}-ecs-sg"
  }
}
resource "aws_vpc_security_group_ingress_rule" "streamlit_ecs_sg_https_traffic" {
  count = var.create_ecs_security_group ? 1 : 0

  security_group_id            = aws_security_group.streamlit_ecs_sg[0].id
  referenced_security_group_id = aws_security_group.streamlit_alb_sg[0].id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "Allow inbound traffic from ALB Security Group on port 443 (HTTPS)."

  tags = {
    SecurityGroup = "${var.app_name}-ecs-sg"
  }
}
# Egress
resource "aws_vpc_security_group_egress_rule" "streamlit_ecs_sg_alb_all_traffic" {
  count = var.create_ecs_security_group ? 1 : 0

  security_group_id = aws_security_group.streamlit_ecs_sg[0].id
  cidr_ipv4         = "0.0.0.0/0"
  # from_port         = 0
  # to_port           = 0
  ip_protocol = "-1"
  description = "Allow outbound traffic to Internet on any port."

  tags = {
    SecurityGroup = "${var.app_name}-ecs-sg"
  }
}

# Create security group for ALB
resource "aws_security_group" "streamlit_alb_sg" {
  count = var.create_alb_security_group ? 1 : 0

  name        = "${var.app_name}-alb-sg"
  vpc_id      = aws_vpc.streamlit_vpc[0].id
  description = "Security group for Streamlit ALB."

  tags = {
    Name = "${var.app_name}-alb-sg"
  }
}
# ECS Security Group Rules
# Ingress
resource "aws_vpc_security_group_ingress_rule" "streamlit_alb_sg_alb_traffic" {
  count = var.create_ecs_security_group ? 1 : 0

  security_group_id = aws_security_group.streamlit_alb_sg[0].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.container_port
  to_port           = var.container_port
  ip_protocol       = "tcp"
  description       = "Allow inbound traffic from Internet on port 8501 (Streamlit default port)."

  tags = {
    SecurityGroup = "${var.app_name}-alb-sg"
  }
}
resource "aws_vpc_security_group_ingress_rule" "streamlit_alb_sg_http_traffic" {
  count = var.create_ecs_security_group ? 1 : 0

  security_group_id = aws_security_group.streamlit_alb_sg[0].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow inbound traffic from Internet on port 80 (HTTP)."

  tags = {
    SecurityGroup = "${var.app_name}-alb-sg"
  }
}
resource "aws_vpc_security_group_ingress_rule" "streamlit_alb_sg_https_traffic" {
  count = var.create_ecs_security_group ? 1 : 0

  security_group_id = aws_security_group.streamlit_alb_sg[0].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow inbound traffic from Internet on port 443 (HTTPS)."

  tags = {
    SecurityGroup = "${var.app_name}-alb-sg"
  }
}
# Egress
resource "aws_vpc_security_group_egress_rule" "streamlit_alb_sg_alb_all_traffic" {
  count = var.create_ecs_security_group ? 1 : 0

  security_group_id = aws_security_group.streamlit_alb_sg[0].id
  cidr_ipv4         = "0.0.0.0/0"
  # from_port         = 0
  # to_port           = 0
  ip_protocol = "-1"
  description = "Allow outbound traffic to Internet on any port."

  tags = {
    SecurityGroup = "${var.app_name}-alb-sg"
  }
}


################################################################################
# Load Balancer
################################################################################
# Create ALB
resource "aws_lb" "streamlit_alb" {
  count = var.create_vpc_resources ? 1 : 0

  name                       = "${var.app_name}-alb"
  internal                   = false
  load_balancer_type         = "application"
  drop_invalid_header_fields = true
  subnets                    = var.existing_alb_subnets != null ? var.existing_alb_subnets : [aws_subnet.public_subnet1[0].id, aws_subnet.public_subnet2[0].id]
  security_groups            = var.existing_alb_security_groups != null ? var.existing_alb_security_groups : [aws_security_group.streamlit_alb_sg[0].id]

  tags = {
    Name = "${var.app_name}-alb"
  }
}

# Configure target group for ALB
resource "aws_lb_target_group" "streamlit_tg" {
  name        = "${var.app_name}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.streamlit_vpc[0].id
  health_check {
    path                = "/healthz"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.app_name}-tg"
  }
}

# Create Listener for ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.streamlit_alb[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.streamlit_tg.arn
  }
}

# Create deny rule for ALB. This prevents users from accessing the ALB directly. Instead, they must go throught CloudFront.
resource "aws_lb_listener_rule" "deny_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.streamlit_tg.arn
  }

  condition {
    http_header {
      http_header_name = var.custom_header_name
      values           = [var.custom_header_value]
    }
  }
}

# Create redirect rule for ALB where users must instead use CloudFront.
resource "aws_lb_listener_rule" "redirect_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 5

  action {
    type = "redirect"

    redirect {
      host        = aws_cloudfront_distribution.streamlit_distribution.domain_name
      path        = "/"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}


################################################################################
# CloudFront
################################################################################
# Create CloudFront distribution
resource "aws_cloudfront_distribution" "streamlit_distribution" {
  origin {
    domain_name = aws_lb.streamlit_alb[0].dns_name
    origin_id   = "${var.app_name}-origin"

    custom_header {
      name  = var.custom_header_name
      value = var.custom_header_value
    }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.app_name}-origin"

    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Caching Disabled
    origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3" # AllViewer
    response_headers_policy_id = "60669652-455b-4ae9-85a4-c4c02393f86c" # SimpleCORS policy ID
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Invalidate CloudFront cache when the Docker container is updated
resource "null_resource" "streamlit_cloudfront_invalidation" {
  count = var.enable_auto_cloudfront_invalidation ? 1 : 0
  # Will only trigger this resource to re-run if changes are made to the Dockerfile
  triggers = {
    src_hash = data.archive_file.streamlit_assets.output_sha
  }

  # Create invalidation when new version of app is uploaded to S3
  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.streamlit_distribution.id} --paths '/*'"

  }

  # Only create invalidation when new version of app is uploaded to S3
  depends_on = [
    # aws_s3_object.streamlit_assets,
    # Temporary workaround until this GitHub issue on aws_s3_object is resolved: https://github.com/hashicorp/terraform-provider-aws/issues/12652
    # data.aws_s3_object.streamlit_assets.key,
    null_resource.put_s3_object,
    aws_cloudfront_distribution.streamlit_distribution
  ]
}


################################################################################
# ECS
################################################################################
# Create ECS Cluster
resource "aws_ecs_cluster" "streamlit_ecs_cluster" {
  name = "${var.app_name}-ecs-cluster"

}

resource "aws_ecs_cluster_capacity_providers" "streamlit_ecs_cluster" {
  cluster_name = aws_ecs_cluster.streamlit_ecs_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# Create ECS Service
resource "aws_ecs_service" "streamlit_ecs_service" {
  name            = "${var.app_name}-ecs-service"
  cluster         = aws_ecs_cluster.streamlit_ecs_cluster.id
  task_definition = aws_ecs_task_definition.streamlit_ecs_task_definition.arn
  desired_count   = var.desired_count # Number of tasks to run
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.existing_ecs_subnets != null ? var.existing_ecs_subnets : [aws_subnet.private_subnet1[0].id, aws_subnet.private_subnet2[0].id]
    security_groups = var.existing_ecs_security_groups != null ? var.existing_ecs_security_groups : [aws_security_group.streamlit_ecs_sg[0].id]

    assign_public_ip = true

  }

  load_balancer {
    target_group_arn = aws_lb_target_group.streamlit_tg.arn
    container_name   = "${var.app_name}-container"
    container_port   = var.container_port
  }
  # The Amazon ECS service requires an explicit dependency on the Application Load Balancer listener rule and the Application Load Balancer listener. This prevents the service from starting before the listener is ready.
  depends_on = [aws_lb_listener.http]
}

# Create CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "streamlit_ecs_service_log_group" {
  name              = "/ecs/${var.app_name}-ecs-log-group"
  retention_in_days = 365
}

# Create ECS Task
resource "aws_ecs_task_definition" "streamlit_ecs_task_definition" {
  family                   = "${var.app_name}-ecs-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu    # CPU units for Fargate (must be number, not string)
  memory                   = var.task_memory # Memory in MiB for Fargate (must be number, not string)
  task_role_arn            = var.existing_ecs_role != null ? var.existing_ecs_role : aws_iam_role.ecs_default_role[0].arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  # Important: all numbers must not be in strings, see this: https://github.com/hashicorp/terraform-provider-aws/issues/6380
  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-container",
      image     = "${aws_ecr_repository.streamlit_ecr_repo.repository_url}:${var.ecs_task_desired_image_tag != null ? var.ecs_task_desired_image_tag : data.aws_s3_object.streamlit_assets.version_id}",
      cpu       = var.task_cpu    # CPU units for Fargate (must be number, not string)
      memory    = var.task_memory # Memory in MiB for Fargate (must be number, not string)
      essential = true,
      portMappings = [
        {
          containerPort = var.container_port,
          hostPort      = var.container_port,
          protocol      = "tcp"
        }
      ],

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.streamlit_ecs_service_log_group.name,
          "awslogs-region"        = var.aws_region != null ? var.aws_region : data.aws_region.current.name,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = var.ecs_operating_system_family
    cpu_architecture        = var.ecs_cpu_architecture
  }

  tags = {
    Name        = "${var.app_name}-ecs-task"
    Environment = var.environment
  }

}


################################################################################
# ECR
################################################################################
# Create an ECR repository
resource "aws_ecr_repository" "streamlit_ecr_repo" {
  name = "${var.app_name}-repo"

  # allow for reppo to be deleted even if it contains images
  force_delete = var.streamlit_ecr_repo_enable_force_delete
}

# TODO - Consider adding support for ECR Lifecycle rules in future module verison
# resource "aws_ecr_lifecycle_policy" "streamlit_ecr_repo" {
#   count = var.create_streamlit_ecr_repo_lifecycle_rules ? 1: 0
#   repository = aws_ecr_repository.streamlit_ecr_repo.name

#   policy = jsonencode({ "rules" : var.streamlit_ecr_repo_lifecycle_rules })

# }


################################################################################
# S3
################################################################################
# Create .zip of Streamlit App Assets
# resource "archive_file" "streamlit_assets" {
#   type = "zip"
#   # source_dir  = "${path.module}/../app/"
#   source_dir  = var.path_to_app_dir != null ? var.path_to_app_dir : "${path.module}/../app/"
#   output_path = "${var.app_name}-assets.zip"
# }
data "archive_file" "streamlit_assets" {
  type = "zip"
  # source_dir  = "${path.module}/../app/"
  source_dir  = var.path_to_app_dir != null ? var.path_to_app_dir : "${path.root}/app/"
  output_path = "${var.app_name}-assets.zip"
}
# Create S3 bucket to store Streamlit Assets
resource "aws_s3_bucket" "streamlit_s3_bucket" {
  bucket        = "${var.app_name}-assets-${random_string.streamlit_s3_bucket.result}"
  force_destroy = true
  tags = {
    Name = "${var.app_name}-assets-${random_string.streamlit_s3_bucket.result}"
  }
}
# Enable S3 Notifcations to use EventBridge
resource "aws_s3_bucket_notification" "streamlit_s3_bucket" {
  bucket      = aws_s3_bucket.streamlit_s3_bucket.id
  eventbridge = true
}
# Enable S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "streamlit_s3_bucket" {
  bucket = aws_s3_bucket.streamlit_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Restrict S3:PutObject unless the file is the Streamlit asset file
data "aws_iam_policy_document" "streamlit_s3_bucket" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id,
      ]
    }
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    # Allows S3:PutObject but only if the file being uploaded is the Streamlit .zip file
    resources = [
      # aws_s3_bucket.streamlit_s3_bucket.id,
      "${aws_s3_bucket.streamlit_s3_bucket.arn}/${var.app_name}-assets.zip",
    ]
  }
  statement {
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id,
      ]
    }
    effect = "Deny"
    actions = [
      "s3:PutObject",
    ]
    # Allows S3:PutObject but only if the file being uploaded is the Streamlit Assets .zip file
    not_resources = [
      "${aws_s3_bucket.streamlit_s3_bucket.arn}/${var.app_name}-assets.zip",
    ]
  }
}

resource "aws_s3_bucket_policy" "streamlit_s3_bucket" {
  bucket = aws_s3_bucket.streamlit_s3_bucket.id
  policy = data.aws_iam_policy_document.streamlit_s3_bucket.json
}
# Push .zip file to S3 bucket
# resource "aws_s3_object" "streamlit_assets" {
#   bucket      = aws_s3_bucket.streamlit_s3_bucket.id
#   key         = "${var.app_name}-assets.zip"
#   source      = "${var.app_name}-assets.zip"
#   source_hash = filemd5("${var.app_name}-assets.zip")
#   depends_on = [
#     aws_s3_bucket.streamlit_s3_bucket,
#     aws_s3_bucket_notification.streamlit_s3_bucket,
#     aws_s3_bucket_policy.streamlit_s3_bucket,
#     aws_s3_bucket_versioning.streamlit_s3_bucket
#   ]
# }

# Temporary workaround until this GitHub issue on aws_s3_object is resolved: https://github.com/hashicorp/terraform-provider-aws/issues/12652
resource "null_resource" "put_s3_object" {
  # Will only trigger this resource to re-run if changes are made to the Dockerfile
  triggers = {
    src_hash = data.archive_file.streamlit_assets.output_sha
  }

  # Put .zip file for Streamlit App Assets in S3 Bucket
  provisioner "local-exec" {
    command = "aws s3 cp ${var.app_name}-assets.zip s3://${aws_s3_bucket.streamlit_s3_bucket.id}/${var.app_name}-assets.zip"

  }

  # Only attempt to put the file when the S3 Bucket (and related resources) are created
  depends_on = [
    aws_s3_bucket.streamlit_s3_bucket,
    aws_s3_bucket_notification.streamlit_s3_bucket,
    aws_s3_bucket_policy.streamlit_s3_bucket,
    aws_s3_bucket_versioning.streamlit_s3_bucket
  ]
}

# Create S3 bucket to store CodePipeline Artifacts
resource "aws_s3_bucket" "streamlit_codepipeline_artifacts" {
  bucket        = "${var.app_name}-pipeline-artifacts-${random_string.streamlit_s3_bucket.result}"
  force_destroy = true
  tags = {
    Name = "${var.app_name}-pipeline-artifacts-${random_string.streamlit_s3_bucket.result}"
  }
}


################################################################################
# EventBridge
################################################################################
# Create Streamlit Event Bus
resource "aws_cloudwatch_event_bus" "streamlit_event_bus" {
  name = "${var.app_name}-event_bus"
  tags = merge(
    {
      "Name" = "${var.app_name}-event_bus"
    },
    var.tags,
  )
}
# Create Rule to forward S3:PutObject events from Default Event Bus to Streamlit Event Bus
resource "aws_cloudwatch_event_rule" "default_event_bus_to_streamlit_event_bus" {
  name          = "${var.app_name}-default_event_bus_to_${var.app_name}-event_bus"
  description   = "Send all defined events from default event bus to Streamlit event bus."
  role_arn      = aws_iam_role.eventbridge_invoke_streamlit_event_bus.arn
  force_destroy = var.eventbridge_rules_enable_force_destroy
  event_pattern = jsonencode({
    source = ["aws.s3"],
    detail-type = [
      "Object Access Tier Changed",
      "Object ACL Updated",
      "Object Created",
      "Object Deleted",
      "Object Restore Completed",
      "Object Restore Expired",
      "Object Restore Initiated",
      "Object Storage Class Changed",
      "Object Tags Added",
      "Object Tags Deleted"
    ],
    detail = {
      bucket = {
        name = [
          aws_s3_bucket.streamlit_s3_bucket.id,
        ]
      }
    }
  })

  tags = merge(
    var.tags,
    {
      "Name" = "${var.app_name}-default_event_bus_to_${var.app_name}-event_bus"
    },
  )
}
resource "aws_cloudwatch_event_target" "default_event_bus_to_streamlit_event_bus" {
  rule      = aws_cloudwatch_event_rule.default_event_bus_to_streamlit_event_bus.name
  target_id = aws_cloudwatch_event_bus.streamlit_event_bus.name
  arn       = aws_cloudwatch_event_bus.streamlit_event_bus.arn
  role_arn  = aws_iam_role.eventbridge_invoke_streamlit_event_bus.arn
}

# Create rule to invoke Streamlit CodePipeline when object is uploaded to Streamlit S3 Bucket
resource "aws_cloudwatch_event_rule" "invoke_streamlit_codepipeline" {
  name           = "${var.app_name}-invoke-streamlit-codepipeline"
  event_bus_name = aws_cloudwatch_event_bus.streamlit_event_bus.name
  description    = "Invoke Streamlit CodePipeline when object is uploaded to Streamlit S3 Bucket."
  role_arn       = aws_iam_role.eventbridge_invoke_streamlit_codepipeline.arn
  force_destroy  = var.eventbridge_rules_enable_force_destroy
  event_pattern = jsonencode({
    source = ["aws.s3"],
    detail-type = [
      "Object Created",
    ],
    detail = {
      bucket = {
        name = [
          aws_s3_bucket.streamlit_s3_bucket.id,
        ]
      }
    }
  })

  tags = merge(
    var.tags,
    {
      "Name" = "${var.app_name}-default_event_bus_to_${var.app_name}-event_bus"
    },
  )
}

resource "aws_cloudwatch_event_target" "streamlit_codepipeline" {
  rule           = aws_cloudwatch_event_rule.invoke_streamlit_codepipeline.name
  target_id      = aws_codepipeline.streamlit_codepipeline.name
  arn            = aws_codepipeline.streamlit_codepipeline.arn
  role_arn       = aws_iam_role.eventbridge_invoke_streamlit_codepipeline.arn
  event_bus_name = aws_cloudwatch_event_bus.streamlit_event_bus.name
}

################################################################################
# CodePipeline
################################################################################
# Create CodePipeline that runs when file is uploaded to S3
resource "aws_codepipeline" "streamlit_codepipeline" {
  name          = "${var.app_name}-pipeline"
  role_arn      = aws_iam_role.streamlit_codepipeline_service_role.arn
  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.streamlit_codepipeline_artifacts.id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "PullFromS3"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output_artifacts"]

      configuration = {
        S3Bucket = aws_s3_bucket.streamlit_s3_bucket.id
        # S3ObjectKey          = aws_s3_object.streamlit_assets.key
        # Temporary workaround until this GitHub issue on aws_s3_object is resolved: https://github.com/hashicorp/terraform-provider-aws/issues/12652
        S3ObjectKey          = data.aws_s3_object.streamlit_assets.key
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "StreamlitCodeBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output_artifacts"]
      output_artifacts = ["build_output_artifacts"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.streamlit_codebuild_project.name
      }
    }
  }

  depends_on = [
    # aws_s3_object.streamlit_assets,
    aws_s3_bucket.streamlit_s3_bucket,
    # Temporary workaround until this GitHub issue on aws_s3_object is resolved: https://github.com/hashicorp/terraform-provider-aws/issues/12652
    null_resource.put_s3_object
  ]
}

################################################################################
# CodeBuild
################################################################################
resource "aws_codebuild_project" "streamlit_codebuild_project" {
  name          = "${var.app_name}-image-builder"
  description   = "CodeBuild project that creates Docker image and pushes to ECR when file is uploaded to ${var.app_name}-assets-${random_string.streamlit_s3_bucket.result} S3 bucket."
  build_timeout = "10"
  # TODO - allow for users to supply existing IAM role to be used with CodeBuild
  service_role = aws_iam_role.streamlit_codebuild_service_role.arn
  # service_role  = var.codebuild_service_role_arn != null ? var.codebuild_service_role_arn : aws_iam_role.codebuild_service_role.arn

  environment {
    compute_type = var.codebuild_compute_type
    image        = var.codebuild_image
    type         = var.codebuild_image_type
    environment_variable {
      name  = "APP_NAME"
      value = var.app_name
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = var.app_version
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${var.app_name}-repo"
    }
    environment_variable {
      name  = "IMAGE_REPO_URL"
      value = aws_ecr_repository.streamlit_ecr_repo.repository_url
    }
    environment_variable {
      name  = "STREAMLIT_S3_BUCKET"
      value = aws_s3_bucket.streamlit_s3_bucket.id
    }
    environment_variable {
      name  = "STREAMLIT_S3_OBJECT"
      value = "${var.app_name}-assets.zip"
    }
    environment_variable {
      name  = "AWS_REGION"
      value = data.aws_region.current.name
    }

  }

  source {
    type     = "S3"
    location = "${aws_s3_bucket.streamlit_s3_bucket.id}/${var.app_name}-assets.zip"

    buildspec = var.path_to_build_spec != null ? file(var.path_to_build_spec) : <<EOF
      version: 0.2
      phases:
        pre_build:
          commands:
            # Fetch the S3 object version id of the latest version of the app and store as environment variable
            - echo Fetching the S3 object version id of the latest version of $APP_NAME...
            - export LATEST_VERSION_ID=${data.aws_s3_object.streamlit_assets.version_id}
            - echo $LATEST_VERSION_ID
            # Log into Amazon ECR
            - echo Logging in to Amazon ECR...
            - aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $IMAGE_REPO_URL
        build:
          commands:
            # Build docker image using latest, app version and s3 object version id as tags
            - echo Build started on `date`
            - echo Building the Docker image...
            - docker build -t $IMAGE_REPO_URL:latest -t $IMAGE_REPO_URL:$IMAGE_TAG -t $IMAGE_REPO_URL:$LATEST_VERSION_ID .
            - echo Build completed on `date`
        post_build:
          commands:
            # Push image with all tags to Amazon ECR
            - echo Pushing the Docker image...
            - docker push $IMAGE_REPO_URL --all-tags
            - echo New image successfully pushed to ECR!
    EOF

  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.app_name}-image-builder"
    },
  )

}


################################################################################
# IAM
################################################################################
# - Trust Relationships -
# EventBridge
data "aws_iam_policy_document" "eventbridge_trust_relationship" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}
# CodePipeline
data "aws_iam_policy_document" "codepipeline_trust_relationship" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}
# CodeBuild
data "aws_iam_policy_document" "codebuild_trust_relationship" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}
# ECS - Tasks
data "aws_iam_policy_document" "ecs_tasks_trust_relationship" {
  count = var.create_ecs_default_role ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# - Policies -
# EventBridge
data "aws_iam_policy_document" "eventbridge_invoke_streamlit_event_bus_policy" {
  statement {
    effect = "Allow"
    actions = [
      "events:PutEvents",
    ]
    resources = [
      aws_cloudwatch_event_bus.streamlit_event_bus.arn,
    ]
  }
}
resource "aws_iam_policy" "eventbridge_invoke_streamlit_event_bus_policy" {
  name        = "${var.app_name}-eventbridge-invoke-streamlit-event-bus"
  description = "Policy to events on the Default Event Bus to invoke the Streamlit Event Bus."
  policy      = data.aws_iam_policy_document.eventbridge_invoke_streamlit_event_bus_policy.json

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-eventbridge-invoke-streamlit-event-bus"
    },
  )
}
data "aws_iam_policy_document" "eventbridge_invoke_streamlit_codepipeline_policy" {
  statement {
    effect = "Allow"
    actions = [
      # "codepipeline:*",
      "codepipeline:StartPipelineExecution",
    ]
    resources = [
      aws_codepipeline.streamlit_codepipeline.arn,
    ]
  }
}
resource "aws_iam_policy" "eventbridge_invoke_streamlit_codepipeline_policy" {
  name        = "${var.app_name}-eventbridge-invoke-streamlit-codepipeline"
  description = "Policy that allows EventBridge to invoke the Streamlit CodePipeline."
  policy      = data.aws_iam_policy_document.eventbridge_invoke_streamlit_codepipeline_policy.json

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-eventbridge-invoke-streamlit-codepipeline"
    },
  )
}
# CodePipeline
data "aws_iam_policy_document" "streamlit_codepipeline_policy" {
  # S3 Allow
  statement {
    effect = "Allow"
    actions = [
      # "s3:*",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]
    resources = [
      aws_s3_bucket.streamlit_s3_bucket.arn,
      "${aws_s3_bucket.streamlit_s3_bucket.arn}/*",
      aws_s3_bucket.streamlit_codepipeline_artifacts.arn,
      "${aws_s3_bucket.streamlit_codepipeline_artifacts.arn}/*",
    ]
  }
  # CodeBuild Allow
  statement {
    effect = "Allow"
    actions = [
      # "codebuild:*",
      "codebuild:StartBuild",
      "codebuild:StopBuild",
      "codebuild:StartBuildBatch",
      "codebuild:StopBuildBatch",
      "codebuild:RetryBuild",
      "codebuild:RetryBuildBatch",
      "codebuild:BatchGet*",
      "codebuild:GetResourcePolicy",
      "codebuild:DescribeTestCases",
      "codebuild:DescribeCodeCoverages",
      "codebuild:List*",
    ]
    # resources = ["*"]
    resources = [aws_codebuild_project.streamlit_codebuild_project.arn]
  }

}
resource "aws_iam_policy" "streamlit_codepipeline_policy" {
  name        = "${var.app_name}-codepipeline-service-role-policy"
  description = "Policy granting AWS CodePipeline access to S3 and CodeBuild."
  policy      = data.aws_iam_policy_document.streamlit_codepipeline_policy.json
}

# CodeBuild
data "aws_iam_policy_document" "streamlit_codebuild_policy" {
  # S3 Allow
  statement {
    effect = "Allow"
    actions = [
      # "s3:*",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:PutObjectTagging",
    ]
    resources = [
      aws_s3_bucket.streamlit_s3_bucket.arn,
      "${aws_s3_bucket.streamlit_s3_bucket.arn}/*",
      aws_s3_bucket.streamlit_codepipeline_artifacts.arn,
      "${aws_s3_bucket.streamlit_codepipeline_artifacts.arn}/*",
    ]
  }
  # ECR Allow
  statement {
    effect = "Allow"
    actions = [
      "ecr:*",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = [
      aws_ecr_repository.streamlit_ecr_repo.arn,
      "*"
    ]
  }
  # CloudWatch Allow
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      # aws_cloudwatch_log_group.streamlit_ecs_service_log_group.arn
      # "arn:aws:logs:${data.aws_region.current.name}${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.app_name}-image-builder:log-stream:*"
      "*",
      "arn:aws:logs:${data.aws_region.current.name}${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.app_name}-image-builder:log-stream:*"
    ]
  }
}
resource "aws_iam_policy" "streamlit_codebuild_policy" {
  name        = "${var.app_name}-codebuild-service-role-policy"
  description = "Policy granting the Streamlit CodeBuild Project access to ECR, S3, and CloudWatch."
  policy      = data.aws_iam_policy_document.streamlit_codebuild_policy.json
}
# ECS Default Policy
data "aws_iam_policy_document" "ecs_default_policy" {
  count = var.create_ecs_default_policy ? 1 : 0
  # ECR Allow
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = [
      aws_ecr_repository.streamlit_ecr_repo.arn
    ]
  }
  # CloudWatch Allow
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.streamlit_ecs_service_log_group.arn
    ]
  }
}
resource "aws_iam_policy" "ecs_default_policy" {
  count = var.create_ecs_default_policy ? 1 : 0

  name        = "${var.app_name}-ecs-default-policy"
  description = "Policy granting permissions for ECS to ECR and CloudWatch."
  policy      = data.aws_iam_policy_document.ecs_default_policy[0].json

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-ecs-default-policy"
    },
  )
}

# - Roles -
# EventBridge
resource "aws_iam_role" "eventbridge_invoke_streamlit_event_bus" {
  name                  = "${var.app_name}-eventbridge-invoke-streamlit-event-bus"
  assume_role_policy    = data.aws_iam_policy_document.eventbridge_trust_relationship.json
  force_detach_policies = true
  managed_policy_arns = [
    aws_iam_policy.eventbridge_invoke_streamlit_event_bus_policy.arn,
  ]
  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-eventbridge-invoke-streamlit-event-bus"
    },
  )
}
resource "aws_iam_role" "eventbridge_invoke_streamlit_codepipeline" {
  name                  = "${var.app_name}-eventbridge-invoke-streamlit-codepipeline"
  assume_role_policy    = data.aws_iam_policy_document.eventbridge_trust_relationship.json
  force_detach_policies = var.enable_force_detach_policies
  managed_policy_arns = [
    aws_iam_policy.eventbridge_invoke_streamlit_codepipeline_policy.arn,
  ]
  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-eventbridge-invoke-streamlit-codepipeline"
    },
  )
}
# CodePipeline
resource "aws_iam_role" "streamlit_codepipeline_service_role" {
  name                  = "${var.app_name}-codepipeline-service-role"
  force_detach_policies = var.enable_force_detach_policies
  assume_role_policy    = data.aws_iam_policy_document.codepipeline_trust_relationship.json
  managed_policy_arns = [
    aws_iam_policy.streamlit_codepipeline_policy.arn,
  ]
  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-codepipeline-service-role"
    },
  )
}
# CodeBuild
resource "aws_iam_role" "streamlit_codebuild_service_role" {
  name                  = "${var.app_name}-codebuild-service-role"
  assume_role_policy    = data.aws_iam_policy_document.codebuild_trust_relationship.json
  force_detach_policies = var.enable_force_detach_policies
  managed_policy_arns = [
    aws_iam_policy.streamlit_codebuild_policy.arn,
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",

  ]
  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-codebuild-service-role"
    },
  )
}

# ECS
resource "aws_iam_role" "ecs_default_role" {
  count = var.create_ecs_default_role ? 1 : 0

  name                  = "${var.app_name}-ecs-default-role"
  assume_role_policy    = data.aws_iam_policy_document.ecs_tasks_trust_relationship[0].json
  force_detach_policies = var.enable_force_detach_policies

  managed_policy_arns = [
    aws_iam_policy.ecs_default_policy[0].arn
  ]
  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-ecs-default-role"
    },
  )
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-ecs-task-execution-role"

  assume_role_policy    = data.aws_iam_policy_document.ecs_tasks_trust_relationship[0].json
  managed_policy_arns   = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
  force_detach_policies = var.enable_force_detach_policies

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-ecs-task-execution-role"
    },
  )
}


