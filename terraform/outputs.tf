output "vpc_id" {
  description = "ID of the Barista Cafe VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "app_instance_id" {
  description = "Application EC2 instance ID"
  value       = aws_instance.app.id
}

output "app_instance_private_ip" {
  description = "Application EC2 private IP"
  value       = aws_instance.app.private_ip
}

output "app_instance_public_ip" {
  description = "Application EC2 public IP"
  value       = aws_instance.app.public_ip
}

output "monitoring_instance_id" {
  description = "Monitoring EC2 instance ID"
  value       = aws_instance.monitoring.id
}

output "monitoring_instance_private_ip" {
  description = "Monitoring EC2 private IP"
  value       = aws_instance.monitoring.private_ip
}

output "monitoring_instance_public_ip" {
  description = "Monitoring EC2 public IP"
  value       = aws_instance.monitoring.public_ip
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.postgres.port
}

output "alb_dns_name" {
  description = "Public DNS name of the application load balancer"
  value       = aws_lb.app.dns_name
}

output "alb_url" {
  description = "Public HTTP URL of the application"
  value       = "http://${aws_lb.app.dns_name}"
}
