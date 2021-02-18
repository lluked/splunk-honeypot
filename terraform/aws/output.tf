output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.splunk-honeypot.public_ip
}

output "splunk" {
  description = "splunk access"
  value       = "${aws_instance.splunk-honeypot.public_ip}/xyz"
}

output "traefik" {
  description = "traefik access"
  value       = "${aws_instance.splunk-honeypot.public_ip}/dashboard/"
}

output "ssh_port" {
  value = "50220"
}

output "ssh_user" {
  value = var.vmUser
}

output "ssh_private_key" {
  value = "./keys/private.pem"
}