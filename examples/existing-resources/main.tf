module "serverless-streamlit-app" {
  source = "../.." # local example
  # source = "aws-ia/serverless-streamlit-app/aws" # remote example

  app_name    = "streamlit-app"
  environment = "dev"
  app_version = "v0.0.1" # used as tag for Docker image. Update this when you wish to push new changes to ECR.

  # Disabled default creation of VPC resources, Security Groups, and IAM Roles/Policies
  create_vpc_resources      = false
  create_alb_security_group = false
  create_ecs_security_group = false

  # Reference your own existing VPC resources, Security Groups, and IAM Roles/Policies
  existing_vpc_id              = var.existing_vpc_id
  existing_alb_subnets         = var.existing_alb_subnets
  existing_ecs_subnets         = var.existing_ecs_subnets
  existing_alb_security_groups = var.existing_alb_security_groups
  existing_ecs_security_groups = var.existing_ecs_security_groups
  existing_route_table_public  = var.existing_route_table_public
  existing_route_table_private = var.existing_route_table_private
}
