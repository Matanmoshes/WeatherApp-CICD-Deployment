# Create an ALB
resource "aws_lb" "app_lb" {
    name               = "app-alb"
    internal           = false
    load_balancer_type = "application"
    subnets            = aws_subnet.app_subnet[*].id

    security_groups = [aws_security_group.alb_sg.id]

    tags = {
    Name = "app-alb"
    }
}

# ALB Listener
resource "aws_lb_listener" "app_lb_listener" {
    load_balancer_arn = aws_lb.app_lb.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.app_tg.arn
    }
}

# Craete a target group for ECS service
resource "aws_lb_target_group" "app_tg" {
    name        = "app-tg"
    port        = 5000
    protocol    = "HTTP"
    vpc_id      = aws_vpc.main.id
    target_type = "ip"

    health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    protocol            = "HTTP"     
    }  
}