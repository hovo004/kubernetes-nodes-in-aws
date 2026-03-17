output "node_public_ips" {
  description = "Public IPs of all K8s nodes"
  value       = aws_eip.this[*].public_ip
}

output "master_public_ip" {
  description = "Public IP of the master node"
  value       = aws_eip.this[0].public_ip
}