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
variable "existing_vpc_id" {
  description = "Existing VPC ID to launch the Streamlit ECS service in."
  type        = string
  default     = null
}

variable "existing_route_table_public" {
  description = "A list of existing public route tables."
  type        = list(string)
  default     = null
}

variable "existing_route_table_private" {
  description = "A list of existing private route tables."
  type        = list(string)
  default     = null
}
