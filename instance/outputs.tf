output "ip" {
  value       = aws_instance.factorio.public_ip
  description = "The public IP address of the server instance."
}
