terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default_vpc_subnets" {
  vpc_id = data.aws_vpc.default.id
}

output "demodb_password" {
  value     = random_password.demodb_password.result
  sensitive = true
}

output "exporter_pk" {
  description = "Private key (pem) that could be used to ssh exporter."
  value       = tls_private_key.exporter.private_key_pem
  sensitive   = true
}

output "exporter_ip" {
  value = aws_spot_instance_request.exporter_instance.public_ip
}