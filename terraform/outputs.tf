# Output the DNS name of the ALB after the deployment
output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
  description = "The DNS name of the ALB"
}
