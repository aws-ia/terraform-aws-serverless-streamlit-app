# - General -
variable "aws_region" {
  description = "The AWS region where the resources will be deployed. Default functionality is to use the region of your current AWS credentials."
  type        = string
  default     = null
}
variable "app_name" {
  description = "The name of your application. This value is appended at the beginning of resource names."
  type        = string
  default     = "streamlit"
}
variable "app_version" {
  description = "The version of the application. This is set to be used as the tag for the Docker image. Defaults to latest. Update this variable when making changes to your application to ensure you don't overwrite your previous image. Overwriting your previous image will prevent you from being able to roll back if you need."
  type        = string
  default     = "v0.0.1"
}
variable "path_to_app_dir" {
  description = "The path to the directory that contains all assets for your Streamlit project. Any changes made to this directory will trigger the Docker image to be rebuilt and pushed to ECR during subsequent applies."
  type        = string
  default     = null
}
variable "environment" {
  description = "The application environment where the resources will be deployed. e.g. 'dev', 'prod', etc."
  type        = string
  default     = "dev"
}

# - VPC -
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}
variable "create_vpc_resources" {
  description = "Whether to create VPC resources. If this is set to `false`, you must provide the relevant ids for your existing resources (e.g VPC, Subnets, Security Groups, etc.)"
  type        = bool
  default     = true
}
variable "existing_vpc_id" {
  description = "The existing VPC ID."
  type        = string
  default     = true
}
variable "existing_alb_security_groups" {
  type        = list(string)
  description = "A list of existing security group IDs to attach to the Streamlit ECS service load balancer."
  default     = null
}
variable "existing_ecs_security_groups" {
  type        = list(string)
  description = "A list of existing security group IDs to attach to the Streamlit ECS service."
  default     = null
}
variable "create_alb_security_group" {
  description = "Whether to create default ALB security group. If this is set to false, you'll need to provide your own list of security group IDs to the `existing_alb_security_groups` variable."
  type        = bool
  default     = true
}
variable "create_ecs_security_group" {
  description = "Whether to create default ECS security group. If this is set to false, you'll need to provide your own list of security group IDs to the `existing_ecs_security_groups` variable."
  type        = bool
  default     = true
}
variable "existing_alb_subnets" {
  description = "A list of existing subnets to launch the ALB in. Public subnets are recommended."
  type        = list(string)
  default     = null
}
variable "existing_ecs_subnets" {
  description = "A list of existing subnets to launch the ECS service in. Private subnets are recommended."
  type        = list(string)
  default     = null
}
variable "enable_alb_deletion_protection" {
  description = "Whether to enable deletion protection for the Streamlit App Application Load Balancer."
  type        = bool
  default     = false
}
variable "alb_listener_ssl_policy_https" {
  description = "The SSL policy for the ALB HTTPS listener. The default uses the AWS security policy that enables TLS 1.3 with backwards compatibility with TLS 1.2."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}
variable "enable_alb_http_listener" {
  description = "Whether to create the ALB HTTP listener."
  type        = bool
  default     = true
}
variable "enable_alb_https_listener" {
  description = "Whether to create the ALB HTTPS listener."
  type        = bool
  default     = false
}
variable "existing_alb_https_listener_cert" {
  description = "The ARN of an existing ACM certificate to use for the ALB HTTPS listener."
  type        = string
  default     = null
}

# - CloudFront -
variable "custom_header_name" {
  description = "Name of the CloudFront custom header. Prevents ALB from accepting requests from other clients than CloudFront. Any random string is fine."
  type        = string
  default     = "X-Verify-Origin"
}

variable "custom_header_value" {
  description = "Value of the CloudFront custom header. Prevents ALB from accepting requests from other clients than CloudFront. Any random string is fine."
  type        = string
  default     = "streamlit-CloudFront-Distribution"
}

variable "enable_auto_cloudfront_invalidation" {
  description = "This variable conditionally enables CloudFront invalidations to automatically occur when there are updates to your Streamlit App."
  type        = bool
  default     = true
}


# - ECS -
variable "container_port" {
  description = "The port number for the ECS container. Default is 8501 (Streamlit default port)."
  type        = number
  default     = 8501
}
variable "ecs_task_desired_image_tag" {
  description = "The desired tag of the image in ECR you wish to use for your ECS Task. If using multiple tags, you can use this to speficy a specific tag (e.g. `v0.0.1`) to use. Default value is to use the version id image tag."
  type        = string
  default     = null
}
variable "desired_count" {
  description = "The desired number of ECS tasks to run. Default is 1."
  type        = number
  default     = 1
}
variable "task_cpu" {
  description = "The CPU resources (in CPU units) allocated to each task. Default is 256."
  type        = number
  default     = 256
}
variable "task_memory" {
  description = "The memory (in MiB) allocated to each task. Default is 512."
  type        = number
  default     = 512
}
variable "ecs_operating_system_family" {
  description = "Operating system family (windows or linux) for the ECS task (x86_64 or arm64). Default is linux. Valid values are listed here: https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_RuntimePlatform.html"
  type        = string
  default     = "LINUX"
}
variable "ecs_cpu_architecture" {
  description = "ECS CPU architecture (x86_64 or arm64). Acceptable values are 'X86_64' or 'ARM64' (case-sensistive)."
  type        = string
  default     = "ARM64" # Change based on your platform
}


# - ECR -
variable "streamlit_ecr_repo_enable_force_delete" {
  description = "Enable force delete on the ECR repo. This allows the destruction of all images in the repository."
  type        = bool
  default     = true
}

variable "streamlit_ecr_repo_image_tag_mutability" {
  description = "Whether to enforce images tags to be immutable or not. Valid values are 'MUTABLE' or IMMUTABLE'."
  type        = string
  default     = "MUTABLE"
}
variable "enable_streamlit_ecr_repo_scan_on_push" {
  description = "Whether to enable image scanning on push for ECR repo. This uses the Amazon Inspector service, which will incur additional cost."
  type        = bool
  default     = false
}
variable "streamlit_ecr_repo_encryption_type" {
  description = "The type of encryption for the ECR repo. Valid values are 'AES256' or 'KMS'."
  type        = string
  default     = "AES256"
}
variable "streamlit_ecr_repo_kms_key" {
  description = "The KMS key ID used to encrypt the ECR repo. This is required if encryption_type is 'KMS'. If not specified, the default AWS managed key for ECR is used."
  type        = string
  default     = null
}

variable "create_streamlit_ecr_repo_lifecycle_policy" {
  description = "Conditional creation of ECR Lifecycle policy for the Streamlit ECR repo. Default is to not create any policy."
  type        = bool
  default     = false
}
variable "streamlit_ecr_repo_lifecycle_policy" {
  description = "A JSON string containing the ECR Lifecycle policy for the Streamlit ECR repo."
  type        = string
  default     = null
}
# TODO - Consider adding support for ECR Lifecycle rules in future module verison

# variable "create_streamlit_ecr_repo_lifecycle_rules" {
#   description = "Conditional creation of lifecycle rules for the Streamlit ECR repo. Default is to not create any rules."
#   type        = bool
#   default     = false
# }
# variable "streamlit_ecr_repo_lifecycle_rules" {
#   description = "A list of ECR repository lifecycle rules. To use this variable, you must also set `create_streamlit_ecr_repo_lifecycle_rules = true` or the rules will not be created/applied."
#   type = list(object({
#     rulePriority : number
#     description : string
#     selection : any
#     })
#   )
#   default = [{
#     rule_priority   = 1
#     tag_status      = "tagged"
#     tag_prefix_list = ["test", "test1", "test2"]
#     count_type      = "sinceImagePushed"
#     count_number    = 60
#     },

#     {
#       rule_priority   = 2
#       tag_status      = "tagged"
#       tag_prefix_list = ["prod", "prod1", "prod2"]
#       count_type      = "sinceImagePushed"
#       count_number    = 90
#   }]
# }


# - S3 -

# - EventBridge -
variable "eventbridge_rules_enable_force_destroy" {
  description = "Enable force destroy on all EventBridge rules. This allows the destruction of all events in the rule."
  type        = bool
  default     = true
}

# - CodePipeline -


# - CodeBuild -
variable "path_to_build_spec" {
  description = "The path to the build spec file for CodeBuild. This file should be a YAML file that defines the build process."
  type        = string
  default     = null
}
variable "codebuild_compute_type" {
  description = "The compute type for CodeBuild. Default is building a small instance with ARM architecture."
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}
variable "codebuild_image" {
  description = "The Docker image for CodeBuild. Default is the official AWS CodeBuild Docker image with ARM architecture."
  type        = string
  default     = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
}
variable "codebuild_image_type" {
  description = "The type of Docker image for CodeBuild. Default is 'ARM_CONTAINER'."
  type        = string
  default     = "ARM_CONTAINER"
}


# - IAM -
variable "enable_force_detach_policies" {
  description = "Enable force detaching any policies from IAM roles."
  type        = bool
  default     = true
}
variable "existing_ecs_role" {
  description = "The ARN of an existing ECS role to assign to the cluster."
  type        = string
  default     = null
}
variable "create_ecs_default_role" {
  description = "Whether to create a default ECS role for the cluster."
  type        = bool
  default     = true
}
variable "create_ecs_default_policy" {
  description = "Whether to create a default ECS policy for the cluster."
  type        = bool
  default     = true
}

# - CloudWatch -
variable "streamlit_ecs_service_log_group_kms_key" {
  description = "The KMS key ID used to encrypt the log group for the ECS service."
  type        = string
  default     = null
}

# - Tags -
variable "tags" {
  type        = map(any)
  description = "Tags to apply to resources."
  default = {
    "IAC_PROVIDER" = "Terraform"
  }
}
