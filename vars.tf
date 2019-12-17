variable "aws_region" {
  default = "eu-central-1"
}

variable "aws_profile" {
  default = "default"
}

variable "allowed_cidr" {
  type = list(string)
}

variable "exporter_instance_cfg" {
  description = "Spot instances configuration for the exporter."
  type = object({
    spot_price    = number
    instance_type = string
  })
}