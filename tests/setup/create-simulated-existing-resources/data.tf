data "aws_region" "current" {
}


# Fetch all available AZs in current AWS Region
data "aws_availability_zones" "available" {
  state = "available"
}
