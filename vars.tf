variable "aws_region" {
  default = "eu-central-1"
}

variable "aws_profile" {
  default = "default"
}

variable "create_db" {
  type = bool
}

variable "allowed_cidr" {
  type = list(string)
}

variable "pgbench_instance_cfg" {
  description = "Spot instances configuration for the pgbench."
  type = object({
    spot_price    = number
    instance_type = string
  })
}