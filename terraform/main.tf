provider "aws" {
  region = "us-east-1"
}

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Public Subnets
resource "aws_subnet" "app_subnet" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

# Associate Subnets with the Route Table
resource "aws_route_table_association" "public_rt_assoc" {
  count          = 2
  subnet_id      = element(aws_subnet.app_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id
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

# Create an NLB
resource "aws_lb" "app_lb" {
  name               = "app-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.app_subnet[*].id
}

# Associate the EIP with the NLB
resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Create a target group for the ECS service
resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 5000
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"
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

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "flask_app"
    container_port   = 5000
  }
}

# Elastic IP
resource "aws_eip" "weather_app_eip" {
  vpc = true
}

# NLB Listener
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  protocol          = "TCP"
  port              = 80

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

