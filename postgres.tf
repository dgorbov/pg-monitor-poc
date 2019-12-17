resource "aws_db_parameter_group" "postgres_pg" {
  name   = "postgres-full-monitoring"
  family = "postgres9.6"

  # just to keep here. Put it to 'none'. Can log diffrent queries. No need if log_min_duration_statement is 0.
  parameter {
    name  = "log_statement"
    value = "none"
  }

  # log all db requests with duration. Put value > 0, to log requests with duration > log_min_duration_statement
  parameter {
    name  = "log_min_duration_statement"
    value = "0"
  }

  # just to keep here. Put it 0. Logs only queries duration, no actual SQL
  parameter {
    name  = "log_duration"
    value = "0"
  }

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "pg_stat_statements.track"
    value = "ALL"
  }

  parameter {
    name         = "track_activity_query_size"
    value        = "2048"
    apply_method = "pending-reboot"
  }
}

resource "aws_db_instance" "demodb" {
  count                  = var.create_db ? 1 : 0
  engine                 = "postgres"
  engine_version         = "9.6.11"
  instance_class         = "db.t2.micro"
  allocated_storage      = 5
  storage_type           = "gp2"
  parameter_group_name   = aws_db_parameter_group.postgres_pg.name
  multi_az               = "false"
  publicly_accessible    = "true"
  vpc_security_group_ids = [aws_security_group.allow_postgre_connection.id]

  identifier = "demodb-server"
  name       = "demodb"
  username   = "postgres"
  password   = random_password.demodb_password.result

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  # disable backups to create DB faster
  backup_retention_period = 0
  skip_final_snapshot     = true
}

resource "random_password" "demodb_password" {
  length  = 16
  special = false
}

resource "aws_security_group" "allow_postgre_connection" {
  vpc_id      = data.aws_vpc.default.id
  name        = "allow_postgre_connection"
  description = "Allows access to postgre db on port 5432 from VPC and some IPs if posgre db has option for public access"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = concat(var.allowed_cidr, [data.aws_vpc.default.cidr_block])
  }
  tags = {
    Name = "allow_postgre_connection"
  }
}