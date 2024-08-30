# Configure the AWS provider to use a specific region
provider "aws" {
    region = "us-east-1"
}

# Data source to fetch available availability zones
data "aws_availability_zones" "available" {
    state = "available"
}
