output "elastic_ip" {
  value = aws_eip.weather_app_eip.public_ip
}
