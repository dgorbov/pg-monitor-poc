terraform {
  backend "s3" {
    key            = "terraform/main-state"
    dynamodb_table = "terraform-state-lock"
  }
}