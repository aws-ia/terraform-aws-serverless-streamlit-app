# module "serverless-streamlit-app" {
#   source = "../.." # local example
#   # source = "aws-ia/serverless-streamlit-app/aws" # remote example

#   app_name    = "streamlit-app"
#   environment = "dev"
#   app_version = "v0.0.1" # used as tag for Docker image. Update this when you wish to push new changes to ECR.

#   path_to_app_dir = "./app" # path to the directory containing the files your Streamlit app.

#   # Disabled default creation of VPC resources, Security Groups, and IAM Roles/Policies
#   create_vpc_resources      = false
#   create_alb_security_group = false
#   create_ecs_security_group = false
#   create_ecs_default_policy = false
#   create_ecs_default_role   = false

#   # Reference your own existing VPC resources, Security Groups, and IAM Roles/Policies
#   existing_vpc_id              = "vpc-xxxxx" # desired VPC for the module to use
#   existing_alb_subnets         = ["example-pub-sub-1", "example-pub-sub-2"]
#   existing_ecs_subnets         = ["example-pub-sub"]
#   existing_alb_security_groups = []
#   existing_ecs_security_groups = []


# }
