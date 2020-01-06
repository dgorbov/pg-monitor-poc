terraform {
  backend "s3" {
    key            = "terraform/main-state"
  }
}