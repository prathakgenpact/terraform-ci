# 1. Generate a Terraform data source block for aws_secretsmanager_secret_version that retrieves a secret using the variable secret_name.
data "aws_secretsmanager_secret_version" "example" {
  secret_id = var.secret_name
}

# 2. Write a Terraform locals block that defines secret_data by JSON decoding the secret_string from the aws_secretsmanager_secret_version.example data source..
locals {
  secret_data = jsondecode(data.aws_secretsmanager_secret_version.example.secret_string)
}

# 3. Create a Terraform resource block for an EC2 instance named demo using variables ami_id and instance_type, and include a Name tag set to TerraformDemo..
resource "aws_instance" "demo" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "TerraformDemo"
  }
}

# 4. Create a Terraform output block named retrieved_secret that returns local.secret_data and mark it as sensitive = true.
output "retrieved_secret" {
  description = "The retrieved secret data from AWS Secrets Manager."
  value       = local.secret_data
  sensitive   = true
}

