output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.chat_server.public_ip
}

output "elastic_ip" {
  description = "Elastic IP associated with the instance"
  value       = aws_eip.chat_eip.public_ip
}

output "ssh_connection_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_eip.chat_eip.public_ip}"
}

output "web_url" {
  description = "URL to access the chat app"
  value       = "http://${aws_eip.chat_eip.public_ip}"
}
