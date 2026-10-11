output "public_ip" {
  description = "Public IP of the web server."
  value       = aws_instance.web_server.public_ip
}

output "public_dns" {
  description = "Public DNS name of the web server."
  value       = aws_instance.web_server.public_dns
}

output "ami_id" {
  description = "AMI the instance was built from, for traceability."
  value       = data.aws_ami.ubuntu.id
}

output "ansible_inventory" {
  description = "Paste into ansible/inventory.ini."
  value       = "[webserver]\n${aws_instance.web_server.public_ip} ansible_user=ubuntu"
}
