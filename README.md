<!-- BEGIN_TF_DOCS -->
# AWS Serverless Streamlit App Terraform Module

## Features

- Serverless deployment using ECS, Application Load Balancer, and CloudFront
- Ability to reference existing VPCs, Subnets, Security Groups, and IAM Roles/Policies
- Automated build of Docker Images
- Automated push of Docker Images to Amazon Elastic Container Registry (ECR)
- Configurable automated CloudFront Invalidations
- Dynamic rollback to previous app versions via image tag

## Architecture

### Streamlit App Hosting

![Streamlit App Hosting Arch](architecture/terraform-module-serverless-streamlit-app-hosting-arch.png)

### Streamlit App Deployment Pipeline

![Streamlit App Deployment Pipeline Arch](architecture/terraform-module-serverless-streamlit-app-deployment-pipeline-arch-with-key.png)

## Basic Usage - Simple deployment of sample Streamlit app with default configuration

### Important

**Note:** The basic deployment will create necessary networking and security services for you with the default values defined in the module variables. If you need to reference existing security and networking resources (VPCs, Subnets, Security Groups, IAM Roles/Policies), please visit review the example for existing resources in the `examples` directory.

**Note**: Ensure the architecture of your ECS Task matches your CodeBuild project. For example, if your CodeBuild project uses an ARM environment such as `BUILD_GENERAL1_SMALL` and an ARM image such as `aws/codebuild/amazonlinux2-aarch64-standard:3.0`, you must also set the architecture of your ECS task to be `ARM64`.

The module provides variables named `ecs_cpu_architecture` `codebuild_compute_type`, and `codebuild_image` which can be modified to your desired values. The default values are using ARM.

**Relevant docs**:

- [CodeBuild - Docker images provided by CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html)
- [CodeBuild - Build environment compute modes and types](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html)

```hcl
// This is a template file for a basic deployment.
// Modify the parameters below with your desired values

module "serverless-streamlit-app" {
  source = "aws-ia/serverless-streamlit-app/aws"

  app_name    = "streamlit-app"
  environment = "dev"
  app_version = "v0.0.1" # used as one of the tags for Docker image. Update this when you wish to push new changes to ECR.
}
```

## Contributing

See the `CONTRIBUTING.md` file for information on how to contribute.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 5.58.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.24.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2.2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | = 5.58.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.1.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.streamlit_distribution](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudwatch_event_bus.streamlit_event_bus](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/cloudwatch_event_bus) | resource |
| [aws_cloudwatch_event_rule.default_event_bus_to_streamlit_event_bus](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.invoke_streamlit_codepipeline](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.default_event_bus_to_streamlit_event_bus](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.streamlit_codepipeline](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.streamlit_ecs_service_log_group](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_codebuild_project.streamlit_codebuild_project](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/codebuild_project) | resource |
| [aws_codepipeline.streamlit_codepipeline](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/codepipeline) | resource |
| [aws_ecr_lifecycle_policy.streamlit_ecr_repo](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.streamlit_ecr_repo](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/ecr_repository) | resource |
| [aws_ecs_cluster.streamlit_ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.streamlit_ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.streamlit_ecs_service](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.streamlit_ecs_task_definition](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/ecs_task_definition) | resource |
| [aws_eip.streamlit_eip](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/eip) | resource |
| [aws_iam_policy.ecs_default_policy](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.eventbridge_invoke_streamlit_codepipeline_policy](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.eventbridge_invoke_streamlit_event_bus_policy](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.streamlit_codebuild_policy](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.streamlit_codepipeline_policy](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecs_default_role](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/iam_role) | resource |
| [aws_iam_role.eventbridge_invoke_streamlit_codepipeline](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/iam_role) | resource |
| [aws_iam_role.eventbridge_invoke_streamlit_event_bus](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/iam_role) | resource |
| [aws_iam_role.streamlit_codebuild_service_role](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/iam_role) | resource |
| [aws_iam_role.streamlit_codepipeline_service_role](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/iam_role) | resource |
| [aws_internet_gateway.streamlit_igw](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/internet_gateway) | resource |
| [aws_lb.streamlit_alb](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.https](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/lb_listener_certificate) | resource |
| [aws_lb_listener_rule.deny_rule](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/lb_listener_rule) | resource |
| [aws_lb_listener_rule.redirect_rule](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.streamlit_tg](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/lb_target_group) | resource |
| [aws_nat_gateway.streamlit_ngw](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/nat_gateway) | resource |
| [aws_route_table.streamlit_route_table_private](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/route_table) | resource |
| [aws_route_table.streamlit_route_table_public](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/route_table) | resource |
| [aws_route_table_association.private_subnet1_association](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_subnet2_association](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_subnet1_association](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_subnet2_association](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/route_table_association) | resource |
| [aws_s3_bucket.streamlit_codepipeline_artifacts](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.streamlit_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_notification.streamlit_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_policy.streamlit_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_versioning.streamlit_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/s3_bucket_versioning) | resource |
| [aws_security_group.streamlit_alb_sg](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/security_group) | resource |
| [aws_security_group.streamlit_ecs_sg](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/security_group) | resource |
| [aws_subnet.private_subnet1](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/subnet) | resource |
| [aws_subnet.private_subnet2](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/subnet) | resource |
| [aws_subnet.public_subnet1](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/subnet) | resource |
| [aws_subnet.public_subnet2](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/subnet) | resource |
| [aws_vpc.streamlit_vpc](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/vpc) | resource |
| [aws_vpc_security_group_egress_rule.streamlit_alb_sg_alb_all_traffic](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.streamlit_ecs_sg_alb_all_traffic](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.streamlit_alb_sg_alb_traffic](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.streamlit_alb_sg_http_traffic](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.streamlit_alb_sg_https_traffic](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.streamlit_ecs_sg_alb_traffic](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.streamlit_ecs_sg_http_traffic](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.streamlit_ecs_sg_https_traffic](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/resources/vpc_security_group_ingress_rule) | resource |
| [null_resource.put_s3_object](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.streamlit_cloudfront_invalidation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.streamlit_s3_bucket](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.wait_20_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [archive_file.streamlit_assets](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.codebuild_trust_relationship](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.codepipeline_trust_relationship](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_default_policy](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_tasks_trust_relationship](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eventbridge_invoke_streamlit_codepipeline_policy](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eventbridge_invoke_streamlit_event_bus_policy](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eventbridge_trust_relationship](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.streamlit_codebuild_policy](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.streamlit_codepipeline_policy](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.streamlit_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/data-sources/region) | data source |
| [aws_s3_object.streamlit_assets](https://registry.terraform.io/providers/hashicorp/aws/5.58.0/docs/data-sources/s3_object) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_listener_ssl_policy_https"></a> [alb\_listener\_ssl\_policy\_https](#input\_alb\_listener\_ssl\_policy\_https) | The SSL policy for the ALB HTTPS listener. The default uses the AWS security policy that enables TLS 1.3 with backwards compatibility with TLS 1.2. | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The name of your application. This value is appended at the beginning of resource names. | `string` | `"streamlit"` | no |
| <a name="input_app_version"></a> [app\_version](#input\_app\_version) | The version of the application. This is set to be used as the tag for the Docker image. Defaults to latest. Update this variable when making changes to your application to ensure you don't overwrite your previous image. Overwriting your previous image will prevent you from being able to roll back if you need. | `string` | `"v0.0.1"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region where the resources will be deployed. Default functionality is to use the region of your current AWS credentials. | `string` | `null` | no |
| <a name="input_codebuild_compute_type"></a> [codebuild\_compute\_type](#input\_codebuild\_compute\_type) | The compute type for CodeBuild. Default is building a small instance with ARM architecture. | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_codebuild_image"></a> [codebuild\_image](#input\_codebuild\_image) | The Docker image for CodeBuild. Default is the official AWS CodeBuild Docker image with ARM architecture. | `string` | `"aws/codebuild/amazonlinux2-aarch64-standard:3.0"` | no |
| <a name="input_codebuild_image_type"></a> [codebuild\_image\_type](#input\_codebuild\_image\_type) | The type of Docker image for CodeBuild. Default is 'ARM\_CONTAINER'. | `string` | `"ARM_CONTAINER"` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | The port number for the ECS container. Default is 8501 (Streamlit default port). | `number` | `8501` | no |
| <a name="input_create_alb_security_group"></a> [create\_alb\_security\_group](#input\_create\_alb\_security\_group) | Whether to create default ALB security group. If this is set to false, you'll need to provide your own list of security group IDs to the `existing_alb_security_groups` variable. | `bool` | `true` | no |
| <a name="input_create_ecs_default_policy"></a> [create\_ecs\_default\_policy](#input\_create\_ecs\_default\_policy) | Whether to create a default ECS policy for the cluster. | `bool` | `true` | no |
| <a name="input_create_ecs_default_role"></a> [create\_ecs\_default\_role](#input\_create\_ecs\_default\_role) | Whether to create a default ECS role for the cluster. | `bool` | `true` | no |
| <a name="input_create_ecs_security_group"></a> [create\_ecs\_security\_group](#input\_create\_ecs\_security\_group) | Whether to create default ECS security group. If this is set to false, you'll need to provide your own list of security group IDs to the `existing_ecs_security_groups` variable. | `bool` | `true` | no |
| <a name="input_create_streamlit_ecr_repo_lifecycle_policy"></a> [create\_streamlit\_ecr\_repo\_lifecycle\_policy](#input\_create\_streamlit\_ecr\_repo\_lifecycle\_policy) | Conditional creation of ECR Lifecycle policy for the Streamlit ECR repo. Default is to not create any policy. | `bool` | `false` | no |
| <a name="input_create_vpc_resources"></a> [create\_vpc\_resources](#input\_create\_vpc\_resources) | Whether to create VPC resources. If this is set to `false`, you must provide the relevant ids for your existing resources (e.g VPC, Subnets, Security Groups, etc.) | `bool` | `true` | no |
| <a name="input_custom_header_name"></a> [custom\_header\_name](#input\_custom\_header\_name) | Name of the CloudFront custom header. Prevents ALB from accepting requests from other clients than CloudFront. Any random string is fine. | `string` | `"X-Verify-Origin"` | no |
| <a name="input_custom_header_value"></a> [custom\_header\_value](#input\_custom\_header\_value) | Value of the CloudFront custom header. Prevents ALB from accepting requests from other clients than CloudFront. Any random string is fine. | `string` | `"streamlit-CloudFront-Distribution"` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The desired number of ECS tasks to run. Default is 1. | `number` | `1` | no |
| <a name="input_ecs_cpu_architecture"></a> [ecs\_cpu\_architecture](#input\_ecs\_cpu\_architecture) | ECS CPU architecture (x86\_64 or arm64). Acceptable values are 'X86\_64' or 'ARM64' (case-sensistive). | `string` | `"ARM64"` | no |
| <a name="input_ecs_operating_system_family"></a> [ecs\_operating\_system\_family](#input\_ecs\_operating\_system\_family) | Operating system family (windows or linux) for the ECS task (x86\_64 or arm64). Default is linux. Valid values are listed here: https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_RuntimePlatform.html | `string` | `"LINUX"` | no |
| <a name="input_ecs_task_desired_image_tag"></a> [ecs\_task\_desired\_image\_tag](#input\_ecs\_task\_desired\_image\_tag) | The desired tag of the image in ECR you wish to use for your ECS Task. If using multiple tags, you can use this to speficy a specific tag (e.g. `v0.0.1`) to use. Default value is to use the version id image tag. | `string` | `null` | no |
| <a name="input_enable_alb_deletion_protection"></a> [enable\_alb\_deletion\_protection](#input\_enable\_alb\_deletion\_protection) | Whether to enable deletion protection for the Streamlit App Application Load Balancer. | `bool` | `false` | no |
| <a name="input_enable_alb_http_listener"></a> [enable\_alb\_http\_listener](#input\_enable\_alb\_http\_listener) | Whether to create the ALB HTTP listener. | `bool` | `true` | no |
| <a name="input_enable_alb_https_listener"></a> [enable\_alb\_https\_listener](#input\_enable\_alb\_https\_listener) | Whether to create the ALB HTTPS listener. | `bool` | `false` | no |
| <a name="input_enable_auto_cloudfront_invalidation"></a> [enable\_auto\_cloudfront\_invalidation](#input\_enable\_auto\_cloudfront\_invalidation) | This variable conditionally enables CloudFront invalidations to automatically occur when there are updates to your Streamlit App. | `bool` | `true` | no |
| <a name="input_enable_force_detach_policies"></a> [enable\_force\_detach\_policies](#input\_enable\_force\_detach\_policies) | Enable force detaching any policies from IAM roles. | `bool` | `true` | no |
| <a name="input_enable_streamlit_ecr_repo_scan_on_push"></a> [enable\_streamlit\_ecr\_repo\_scan\_on\_push](#input\_enable\_streamlit\_ecr\_repo\_scan\_on\_push) | Whether to enable image scanning on push for ECR repo. This uses the Amazon Inspector service, which will incur additional cost. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The application environment where the resources will be deployed. e.g. 'dev', 'prod', etc. | `string` | `"dev"` | no |
| <a name="input_eventbridge_rules_enable_force_destroy"></a> [eventbridge\_rules\_enable\_force\_destroy](#input\_eventbridge\_rules\_enable\_force\_destroy) | Enable force destroy on all EventBridge rules. This allows the destruction of all events in the rule. | `bool` | `true` | no |
| <a name="input_existing_alb_https_listener_cert"></a> [existing\_alb\_https\_listener\_cert](#input\_existing\_alb\_https\_listener\_cert) | The ARN of an existing ACM certificate to use for the ALB HTTPS listener. | `string` | `null` | no |
| <a name="input_existing_alb_security_groups"></a> [existing\_alb\_security\_groups](#input\_existing\_alb\_security\_groups) | A list of existing security group IDs to attach to the Streamlit ECS service load balancer. | `list(string)` | `null` | no |
| <a name="input_existing_alb_subnets"></a> [existing\_alb\_subnets](#input\_existing\_alb\_subnets) | A list of existing subnets to launch the ALB in. Public subnets are recommended. | `list(string)` | `null` | no |
| <a name="input_existing_ecs_role"></a> [existing\_ecs\_role](#input\_existing\_ecs\_role) | The ARN of an existing ECS role to assign to the cluster. | `string` | `null` | no |
| <a name="input_existing_ecs_security_groups"></a> [existing\_ecs\_security\_groups](#input\_existing\_ecs\_security\_groups) | A list of existing security group IDs to attach to the Streamlit ECS service. | `list(string)` | `null` | no |
| <a name="input_existing_ecs_subnets"></a> [existing\_ecs\_subnets](#input\_existing\_ecs\_subnets) | A list of existing subnets to launch the ECS service in. Private subnets are recommended. | `list(string)` | `null` | no |
| <a name="input_existing_vpc_id"></a> [existing\_vpc\_id](#input\_existing\_vpc\_id) | The existing VPC ID. | `string` | `true` | no |
| <a name="input_path_to_app_dir"></a> [path\_to\_app\_dir](#input\_path\_to\_app\_dir) | The path to the directory that contains all assets for your Streamlit project. Any changes made to this directory will trigger the Docker image to be rebuilt and pushed to ECR during subsequent applies. | `string` | `null` | no |
| <a name="input_path_to_build_spec"></a> [path\_to\_build\_spec](#input\_path\_to\_build\_spec) | The path to the build spec file for CodeBuild. This file should be a YAML file that defines the build process. | `string` | `null` | no |
| <a name="input_streamlit_ecr_repo_enable_force_delete"></a> [streamlit\_ecr\_repo\_enable\_force\_delete](#input\_streamlit\_ecr\_repo\_enable\_force\_delete) | Enable force delete on the ECR repo. This allows the destruction of all images in the repository. | `bool` | `true` | no |
| <a name="input_streamlit_ecr_repo_encryption_type"></a> [streamlit\_ecr\_repo\_encryption\_type](#input\_streamlit\_ecr\_repo\_encryption\_type) | The type of encryption for the ECR repo. Valid values are 'AES256' or 'KMS'. | `string` | `"AES256"` | no |
| <a name="input_streamlit_ecr_repo_image_tag_mutability"></a> [streamlit\_ecr\_repo\_image\_tag\_mutability](#input\_streamlit\_ecr\_repo\_image\_tag\_mutability) | Whether to enforce images tags to be immutable or not. Valid values are 'MUTABLE' or IMMUTABLE'. | `string` | `"MUTABLE"` | no |
| <a name="input_streamlit_ecr_repo_kms_key"></a> [streamlit\_ecr\_repo\_kms\_key](#input\_streamlit\_ecr\_repo\_kms\_key) | The KMS key ID used to encrypt the ECR repo. This is required if encryption\_type is 'KMS'. If not specified, the default AWS managed key for ECR is used. | `string` | `null` | no |
| <a name="input_streamlit_ecr_repo_lifecycle_policy"></a> [streamlit\_ecr\_repo\_lifecycle\_policy](#input\_streamlit\_ecr\_repo\_lifecycle\_policy) | A JSON string containing the ECR Lifecycle policy for the Streamlit ECR repo. | `string` | `null` | no |
| <a name="input_streamlit_ecs_service_log_group_kms_key"></a> [streamlit\_ecs\_service\_log\_group\_kms\_key](#input\_streamlit\_ecs\_service\_log\_group\_kms\_key) | The KMS key ID used to encrypt the log group for the ECS service. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources. | `map(any)` | <pre>{<br>  "IAC_PROVIDER": "Terraform"<br>}</pre> | no |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | The CPU resources (in CPU units) allocated to each task. Default is 256. | `number` | `256` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | The memory (in MiB) allocated to each task. Default is 512. | `number` | `512` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block for the VPC. | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azs"></a> [azs](#output\_azs) | A list of availability zones for the region of the current AWS profile. |
| <a name="output_streamlit_alb_dns_name"></a> [streamlit\_alb\_dns\_name](#output\_streamlit\_alb\_dns\_name) | DNS name of the Streamlit ALB. |
| <a name="output_streamlit_cloudfront_distribution_url"></a> [streamlit\_cloudfront\_distribution\_url](#output\_streamlit\_cloudfront\_distribution\_url) | URL of the Streamlit CloudFront distribution. |
| <a name="output_streamlit_ecr_repo_image_uri"></a> [streamlit\_ecr\_repo\_image\_uri](#output\_streamlit\_ecr\_repo\_image\_uri) | URI of the Streamlit image in the ECR repository. |
<!-- END_TF_DOCS -->