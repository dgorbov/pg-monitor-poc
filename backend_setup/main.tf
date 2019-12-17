# terraform backend creation. Run it only once!

terraform {
  required_version = ">= 0.12.0"
}

variable "AWS_REGION" {
}

variable "AWS_PROFILE" {
}

variable "S3_BUCKET_NAME" {
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.AWS_REGION
  profile = var.AWS_PROFILE
}

resource "aws_s3_bucket" "terraform-state" {
    bucket = var.S3_BUCKET_NAME
    acl    = "private"
    versioning {
      enabled = true
    }
    lifecycle {
      prevent_destroy = true
    }
    tags = {
      Name = "S3 Remote Terraform State Store"
    }      
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "terraform-state-lock"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "DynamoDB Terraform State Lock Table"
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.terraform-state.bucket
}

output "dynamodb_terraform_state_lock" {
  value = aws_dynamodb_table.dynamodb-terraform-state-lock.name
}

output "aws_region" {
  value = var.AWS_REGION
}