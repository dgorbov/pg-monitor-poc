
resource "aws_security_group" "allow_ssh_exporter" {
  vpc_id      = data.aws_vpc.default.id
  name        = "allow-ssh-exporter"
  description = "security group that allows ssh and all egress traffic to exporter server"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr
  }
  tags = {
    Name = "allow-ssh-exporter"
  }
}

data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"] #Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "tls_private_key" "exporter" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "exporter" {
  key_name   = "exporter"
  public_key = tls_private_key.exporter.public_key_openssh
}

resource "aws_spot_instance_request" "exporter_instance" {
  spot_price           = var.exporter_instance_cfg.spot_price
  wait_for_fulfillment = true
  spot_type            = "one-time"

  ami                         = data.aws_ami.ubuntu_latest.id
  instance_type               = var.exporter_instance_cfg.instance_type
  associate_public_ip_address = true
  subnet_id                   = tolist(data.aws_subnet_ids.default_vpc_subnets.ids)[0]
  vpc_security_group_ids      = [aws_security_group.allow_ssh_exporter.id]
  key_name                    = aws_key_pair.exporter.key_name

  tags = {
    Name        = "exporter-instance"
    Description = "exporter-instance for db monitoring PoC"
  }

  volume_tags = {
    Name        = "exporter-volume"
    Description = "exporter-instance for db monitoring PoC"
  }
}