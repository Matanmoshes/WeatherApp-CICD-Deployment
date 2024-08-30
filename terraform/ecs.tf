# Create an ECS Cluster to manage your containerized application
resource "aws_ecs_cluster" "weather_app_cluster" {
    name = "weather_app_cluster"
}

# Create an IAM role for ECS tasks to allow pulling images and logging
resource "aws_iam_role" "ecs_task_execution_role" {
    name = "ecsTaskExecutionRole"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
        {
            Effect = "Allow",
            Principal = {
                Service = "ecs-tasks.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }
        ]
    })
}

# Attach the necessary policies to the ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
    role       = aws_iam_role.ecs_task_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Define the ECS Task Definition which includes the Docker container settings
resource "aws_ecs_task_definition" "weather_app" {
    family                   = "weather-app-task"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    memory                   = "512"
    cpu                      = "256"
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

    container_definitions = jsonencode([
    {
        name      = "flask_app"
        image     = var.docker_image  # Docker image passed via variable
        essential = true
        portMappings = [{
            containerPort = 5000
            hostPort      = 5000
        }]
        environment = [
            {
            name  = "OPENWEATHER_API_KEY"
            value = var.openweather_api_key
            }
        ]
    }
    ])
}

# Create an ECS Service to run and manage the ECS tasks
resource "aws_ecs_service" "weather_app_service" {
    name            = "weather-app-service"
    cluster         = aws_ecs_cluster.weather_app_cluster.id
    task_definition = aws_ecs_task_definition.weather_app.arn
    desired_count   = 1
    launch_type     = "FARGATE"

    network_configuration {
        subnets = aws_subnet.app_subnet[*].id
        security_groups = [aws_security_group.ecs_sg.id]
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.app_tg.arn
        container_name   = "flask_app"
        container_port   = 5000
    }

    # Attach the service to a service registry
    deployment_minimum_healthy_percent = 50
    deployment_maximum_percent         = 200
}

# ECS Service Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
    max_capacity       = 10
    min_capacity       = 1
    resource_id        = "service/${aws_ecs_cluster.weather_app_cluster.name}/${aws_ecs_service.weather_app_service.name}"
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace  = "ecs"
}

# ECS Service Auto Scaling Policy (Scale Out)
resource "aws_appautoscaling_policy" "ecs_policy_scale_out" {
    name               = "ecs-policy-scale-out"
    service_namespace  = "ecs"
    resource_id        = aws_appautoscaling_target.ecs_target.resource_id
    scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
    policy_type        = "TargetTrackingScaling"

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
        target_value = 50.0  # Trigger scaling out when CPU utilization is above 50%
        scale_out_cooldown = 300
    }
}

# ECS Service Auto Scaling Policy (Scale In)
resource "aws_appautoscaling_policy" "ecs_policy_scale_in" {
    name               = "ecs-policy-scale-in"
    service_namespace  = "ecs"
    resource_id        = aws_appautoscaling_target.ecs_target.resource_id
    scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
    policy_type        = "TargetTrackingScaling"

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
        target_value = 30.0  # Trigger scaling in when CPU utilization is below 30%
        scale_in_cooldown = 300
    }
}