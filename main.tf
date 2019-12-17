terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.AWS_REGION
  profile = var.AWS_PROFILE
}

data "aws_vpc" "default" {
  default = true
}

output "demodb_password" {
  value     = random_password.demodb_password.result
  sensitive = true
}