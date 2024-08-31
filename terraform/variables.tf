# Define the Docker image to be used in the ECS task
variable "docker_image" {
  description = "The Docker image to deploy for the Flask app"
  type = string
  default = "matanm66/weather-app:latest"
}

# Define the OpenWeather API key to be passed to the container
variable "openweather_api_key" {
  description = "The OpenWeather API key"
  type        = string
  sensitive   = true  # Mark as sensitive since it's a secret
}

# Define the CIDR block for the VPC
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Define the CIDR blocks for the public subnets
variable "subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}