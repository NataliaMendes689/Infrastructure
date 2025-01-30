output "public_ip" {
  description = "Public IP da instância EC2"
  value       = aws_instance.web_server.public_ip
}