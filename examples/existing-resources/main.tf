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
  existing_vpc_id              = aws_vpc.sample_existing_vpc.id 
  existing_alb_subnets         = [aws_subnet.sample_existing_public_subnet1.id, aws_subnet.sample_existing_public_subnet2.id]
  existing_ecs_subnets         = [aws_subnet.sample_existing_private_subnet1.id, aws_subnet.sample_existing_private_subnet2.id]
  existing_alb_security_groups = [aws_security_group.sample_existing_lb_sg.id]
  existing_ecs_security_groups = [aws_security_group.sample_existing_ecs_sg.id]
}
