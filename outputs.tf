output "streamlit_ecr_repo_image_uri" {
  description = "URI of the Streamlit image in the ECR repository."
  value       = aws_ecr_repository.streamlit_ecr_repo.repository_url
}
output "streamlit_alb_dns_name" {
  description = "DNS name of the Streamlit ALB."
  value       = aws_lb.streamlit_alb.dns_name
}

output "streamlit_cloudfront_distribution_url" {
  description = "URL of the Streamlit CloudFront distribution."
  value       = "https://${aws_cloudfront_distribution.streamlit_distribution.domain_name}"
}

output "azs" {
  description = "A list of availability zones for the region of the current AWS profile."
  value       = data.aws_availability_zones.available.names

}
