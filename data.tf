# Fetch AWS Region for current AWS credentials (e.g. the IAM role used to deploy Terraform)
data "aws_region" "current" {
}

# Fetch AWS caller identity (i.e. the AWS user or role that Terraform is authenticated as)
data "aws_caller_identity" "current" {
}


# Fetch all available AZs in current AWS Region
data "aws_availability_zones" "available" {
  state = "available"
}


# # Fetch details about ECR image
# data "aws_ecr_image" "streamlit_image" {
#   repository_name = aws_ecr_repository.streamlit_ecr_repo.id
#   image_tag       = var.app_version
#   # image_tag       = "latest"

#   depends_on = [aws_s3_object.streamlit_assets]
# }

# Fetch details about S3 object
data "aws_s3_object" "streamlit_assets" {
  bucket = aws_s3_bucket.streamlit_s3_bucket.id
  key    = "${var.app_name}-assets.zip"

  depends_on = [
    time_sleep.wait_20_seconds,
    aws_s3_bucket.streamlit_s3_bucket,
    null_resource.put_s3_object,
    #aws_s3_bucket_policy.streamlit_s3_bucket,
    # aws_s3_object.streamlit_assets,
    # Temporary workaround until this GitHub issue on aws_s3_object is resolved: https://github.com/hashicorp/terraform-provider-aws/issues/12652    
  ]
}
