<!-- BEGIN_TF_DOCS -->
# Basic Example

This is a basic example of the configuration required to deploy a sample Streamlit app. The application files are stored in the `app/` directory.

## IMPORTANT

Ensure the architecture of your ECS Task matches your CodeBuild project. For example, if your CodeBuild project uses an ARM environment such as `BUILD_GENERAL1_SMALL` and an ARM image such as `aws/codebuild/amazonlinux2-aarch64-standard:3.0`, you must also set the architecture of your ECS task to be `ARM64`.

The module provides variables named `ecs_cpu_architecture` `codebuild_compute_type`, and `codebuild_image` which can be modified to your desired values. The default values are using ARM.

**Relevant docs**:

- [CodeBuild - Docker images provided by CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html)
- [CodeBuild - Build environment compute modes and types](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html)

## About the App directory (name and directory location)

The `app` directory is where you store the files for your Streamlit app. As a note, this can be named anything, however in you need to reference it with the correct path such as `./app` with context to where your Terraform configuration files are. You can change this in the module by using the `path_to_app_dir` variable. For example, take this current directory that has the following structure:

```
basic
├── README.md
├── app
├── main.tf
├── outputs.tf
├── providers.tf
└── variables.tf
```

 Since the Terraform configuration files we are using are in the same directory as the `app/` directory, we can reference that with `path_to_app_dir = "./app"`. Assuming that you keep this same structure but your directory is named `my-streamlit-app` you would need to change the variable to be `path_to_app_dir = "./my-streamlit-app"`. This is used so the module knows where your Streamlit app is located so it can build the Docker image and push it to Amazon Elastic Container Registry (ECR).

 For another example, assume you have your Terraform files all stored in a `terraform-deployment` directory and are still using `app` as the name of your app directory containing your Streamlit app files:

 ```
.
├── app
│   ├── Dockerfile
│   ├── assets
│   ├── requirements.txt
│   └── streamlit_sample.py
└── terraform-deployment
    ├── README.md
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

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azs"></a> [azs](#output\_azs) | n/a |
| <a name="output_streamlit_alb_dns_name"></a> [streamlit\_alb\_dns\_name](#output\_streamlit\_alb\_dns\_name) | n/a |
| <a name="output_streamlit_cloudfront_distribution_url"></a> [streamlit\_cloudfront\_distribution\_url](#output\_streamlit\_cloudfront\_distribution\_url) | n/a |
| <a name="output_streamlit_ecr_repo_image_uri"></a> [streamlit\_ecr\_repo\_image\_uri](#output\_streamlit\_ecr\_repo\_image\_uri) | n/a |
<!-- END_TF_DOCS -->