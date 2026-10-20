output "nlb_dns_name" {
  description = "Open this in your browser"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ec2_instance_1_public_ip" {
  value = aws_instance.web_1.public_ip
}

output "ec2_instance_2_public_ip" {
  value = aws_instance.web_2.public_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}