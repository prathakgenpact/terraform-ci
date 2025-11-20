# 1. Generate a Terraform output block that exposes the public IP of an EC2 instance named aws_instance.demo, including a description.
output "instance_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.demo.public_ip
}

# 2. Write a Terraform output block for a decoded Secrets Manager value stored in local.secret_data. Include a description and mark the output as sensitive.
output "decoded_secret_value" {
  description = "The decoded value of the secret from AWS Secrets Manager."
  value       = local.secret_data
  sensitive   = true
}