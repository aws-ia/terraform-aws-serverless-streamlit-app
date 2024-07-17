<!-- BEGIN_TF_DOCS -->
# Existing Resources Example

This is a example of the configuration required to deploy a sample Streamlit app levering existing security and networking services (VPC, Subnets, Security Groups, IAM Roles/Policies, etc.). The application files are stored in the `app/` directory.

## IMPORTANT

Ensure the architecture of your ECS Task matches your CodeBuild project. For example, if your CodeBuild project uses an ARM environment such as `BUILD_GENERAL1_SMALL` and an ARM image such as `aws/codebuild/amazonlinux2-aarch64-standard:3.0`, you must also set the architecture of your ECS task to be `ARM64`.

The module provides variables named `ecs_cpu_architecture` `codebuild_compute_type`, and `codebuild_image` which can be modified to your desired values. The default values are using ARM.

**Relevant docs**:

- [CodeBuild - Docker images provided by CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html)
- [CodeBuild - Build environment compute modes and types](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html)

## About the App directory (name and directory location)

The `app` directory is where you store the files for your Streamlit app. As a note, this can be named anything, however in you need to reference it with the correct path such as `./app` with context to where your Terraform configuration files are. You can change this in the module by using the `path_to_app_dir` variable. For example, take this current directory that has the following structure:

```
existing-resources
├── README.md
├── app
├── main.tf
├── outputs.tf
├── providers.tf
└── variables.tf
```

 With the above directory structure, your Terraform files are in a separate directory than your `app` directory, specificially it is one level up from the `terraform-deployment` directory. In this case your `path_to_app_dir` should be `path_to_app_dir = "../app"`. Ensure your path is correctly defined or your Docker images will not be built correctly.

## Streamlit App Directory Structure

Your Streamlit App should have generally have the following structure:

```
app
├── .dockerignore
├── .streamlit
│   └── config.toml
├── Dockerfile
├── assets
│   ├── AWS_logo_RGB_REV.png
│   ├── favicon
│   └── tf-logo.png
├── requirements.txt
└── streamlit_sample.py
```

- **Directories/Files**:
  - `Dockerfile` (Required) - the configuration file of how your Docker image should be built
  - `.dockerignore` (Optional but highly recommended) - the file where you define the files/directories you wish to ignore when copying files to the Docker image (e.g. Terraform state files, etc.)
  - `requirements.txt` (Required) - the file containing required packages to be installed for your Streamlit app to function
  - `streamlit_sample.py` - the core file that is used to run your Streamlit app. As a note, this name can be anything you wish. You can also create sub-directories for additional pages, however we recommend keeping the main entrypoint file for your Streamlit app at the top of the directory (not nested in other sub-folders)
  - `.streamlit` (Optional but recommended) - the directory where you place your `config.toml` Streamlit configuration file
    - `config.toml` (Optional) - the Streamlit configuration file
  - assets (Optional) - the directory containing assets for your project (e.g. images, etc.)
  - ...Other files/directories as desired

## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_serverless-streamlit-app"></a> [serverless-streamlit-app](#module\_serverless-streamlit-app) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_existing_alb_security_groups"></a> [existing\_alb\_security\_groups](#input\_existing\_alb\_security\_groups) | A list of existing security group IDs to attach to the Streamlit ECS service load balancer. | `list(string)` | `null` | no |
| <a name="input_existing_alb_subnets"></a> [existing\_alb\_subnets](#input\_existing\_alb\_subnets) | A list of existing subnets to launch the ALB in. Public subnets are recommended. | `list(string)` | `null` | no |
| <a name="input_existing_ecs_security_groups"></a> [existing\_ecs\_security\_groups](#input\_existing\_ecs\_security\_groups) | A list of existing security group IDs to attach to the Streamlit ECS service. | `list(string)` | `null` | no |
| <a name="input_existing_ecs_subnets"></a> [existing\_ecs\_subnets](#input\_existing\_ecs\_subnets) | A list of existing subnets to launch the ECS service in. Private subnets are recommended. | `list(string)` | `null` | no |
| <a name="input_existing_route_table_private"></a> [existing\_route\_table\_private](#input\_existing\_route\_table\_private) | A list of existing private route tables. | `list(string)` | `null` | no |
| <a name="input_existing_route_table_public"></a> [existing\_route\_table\_public](#input\_existing\_route\_table\_public) | A list of existing public route tables. | `list(string)` | `null` | no |
| <a name="input_existing_vpc_id"></a> [existing\_vpc\_id](#input\_existing\_vpc\_id) | Existing VPC ID to launch the Streamlit ECS service in. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azs"></a> [azs](#output\_azs) | n/a |
| <a name="output_streamlit_alb_dns_name"></a> [streamlit\_alb\_dns\_name](#output\_streamlit\_alb\_dns\_name) | n/a |
| <a name="output_streamlit_cloudfront_distribution_url"></a> [streamlit\_cloudfront\_distribution\_url](#output\_streamlit\_cloudfront\_distribution\_url) | n/a |
| <a name="output_streamlit_ecr_repo_image_uri"></a> [streamlit\_ecr\_repo\_image\_uri](#output\_streamlit\_ecr\_repo\_image\_uri) | n/a |
<!-- END_TF_DOCS -->