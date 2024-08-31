# Create a security group for the Application Load Balancer (ALB)
resource "aws_security_group" "alb_sg" {
  name = "alb-sg"
  vpc_id = aws_vpc.main.id

  # Allow inbound HTTP traffic on port 80 from anywhere
  ingress = [
    {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
    } 
  ]
  # Allow all outbound traffic
  egress = [
    {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
    }
  ]
  tags = {
    Name = "alb-sg"
  }
}

# Create a security group for the ECS service
resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg"
  vpc_id = aws_vpc.main.id

  # Allow inbound traffic from the ALB on port 5000
  ingress = [
    {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Allow traffic only from ALB security group
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
    }
  ]

  # Allow all outbound traffic
  egress = [ 
    {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
    }
  ]

  tags = {
    Name = "ecs-sg"
  }
}