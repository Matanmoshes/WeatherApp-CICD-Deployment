provider "aws" {
  region = "us-east-1"
}

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "app_subnet" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

data "aws_availability_zones" "available" {}

# ECS Cluster
resource "aws_ecs_cluster" "weather_app_cluster" {
  name = "weather-app-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "weather_app" {
  family                   = "weather-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "512"
  cpu                      = "256"

  container_definitions = jsonencode([
    {
      name      = "flask_app"
      image     = "${var.docker_image}"
      essential = true
      portMappings = [{
        containerPort = 5000
        hostPort      = 5000
      }]
      environment = [
        {
          name  = "OPENWEATHER_API_KEY"
          value = "${var.openweather_api_key}"
        }
      ]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "weather_app_service" {
  name            = "weather-app-service"
  cluster         = aws_ecs_cluster.weather_app_cluster.id
  task_definition = aws_ecs_task_definition.weather_app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.app_subnet[*].id
    security_groups = [aws_security_group.ecs_sg.id]
  }
}

# Elastic IP
resource "aws_eip" "weather_app_eip" {
  vpc = true
}

# Associate Elastic IP with ECS Service
resource "aws_eip_association" "weather_app_eip_association" {
  allocation_id = aws_eip.weather_app_eip.id
  instance_id   = aws_ecs_service.weather_app_service.id
}
