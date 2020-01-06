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

output "pgbench_ip" {
  value = aws_spot_instance_request.pgbench_instance.public_ip
}