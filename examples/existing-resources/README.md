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

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_serverless-streamlit-app"></a> [serverless-streamlit-app](#module\_serverless-streamlit-app) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eip.sample_existing_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.sample_existing_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.sample_existing_ngw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route_table.sample_existing_route_table_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.sample_existing_route_table_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private_subnet2_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.sample_existing_private_subnet1_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.sample_existing_public_subnet1_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.sample_existing_public_subnet2_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.sample_existing_ecs_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.sample_existing_lb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.sample_existing_private_subnet1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.sample_existing_private_subnet2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.sample_existing_public_subnet1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.sample_existing_public_subnet2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.sample_existing_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | n/a | `string` | `"sample-existing"` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | The port number for the ECS container. Default is 8501 (Streamlit default port). | `number` | `8501` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources. | `map(any)` | <pre>{<br>  "IAC_PROVIDER": "Terraform"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azs"></a> [azs](#output\_azs) | n/a |
| <a name="output_streamlit_alb_dns_name"></a> [streamlit\_alb\_dns\_name](#output\_streamlit\_alb\_dns\_name) | n/a |
| <a name="output_streamlit_cloudfront_distribution_url"></a> [streamlit\_cloudfront\_distribution\_url](#output\_streamlit\_cloudfront\_distribution\_url) | n/a |
| <a name="output_streamlit_ecr_repo_image_uri"></a> [streamlit\_ecr\_repo\_image\_uri](#output\_streamlit\_ecr\_repo\_image\_uri) | n/a |
<!-- END_TF_DOCS -->