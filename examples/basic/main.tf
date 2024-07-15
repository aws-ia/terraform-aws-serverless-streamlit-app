#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "serverless-streamlit-app" {
  source = "../.." # local example
  # source = "aws-ia/serverless-streamlit-app/aws" # remote example

  app_name    = "streamlit-app"
  environment = "dev"
  app_version = "v0.0.1" # used as one of the tags for Docker image. Update this when you wish to push new changes to ECR.
}
