output "ip" {
  value       = aws_instance.factorio.public_ip
  description = "The public IP address of the server instance."
}

output "instance-id" {
  value       = aws_instance.factorio.id
  description = "The instance ID of the server instance."
}
