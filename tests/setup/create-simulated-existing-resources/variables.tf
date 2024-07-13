variable "app_name" {
  type    = string
  default = "sample-existing"
}

variable "container_port" {
  description = "The port number for the ECS container. Default is 8501 (Streamlit default port)."
  type        = number
  default     = 8501
}

variable "tags" {
  type        = map(any)
  description = "Tags to apply to resources."
  default = {
    "IAC_PROVIDER" = "Terraform"
  }
}
