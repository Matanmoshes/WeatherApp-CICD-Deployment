# ECS Cluster
resource "aws_ecs_cluster" "weather_app_cluster" {
    name = "weather_app_cluster"
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

# ECS Services
resource "aws_ecs_service" "weather_app_service" {
    name = "weather-app-service"
    cluster = aws_ecs_cluster.weather_app_cluster.id
    task_definition = aws_ecs_task_definition.weather_app.arn
    desired_count = 1
    launch_type = "FARGATE"

    network_configuration {
        subnets = aws_subnet.app_subnet[*].id
        security_groups = [aws_security_group.ecs_sg.id]
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.app_tg.arn
        container_name = "flask_app"
        container_port = 5000
    }
}