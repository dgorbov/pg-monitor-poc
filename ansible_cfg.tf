resource "local_file" "pgbench_pk" {
  content         = tls_private_key.pgbench.private_key_pem
  filename        = "out/pgbench_pk.pem"
  file_permission = 600
}

resource "local_file" "ansible_hosts" {
  content = templatefile("templates/ansible_hosts", {
    PGBENCH_IP = aws_spot_instance_request.pgbench_instance.public_ip
  })
  filename = "out/hosts"
}

resource "local_file" "ansible_cfg" {
  content  = file("templates/ansible.cfg")
  filename = "out/ansible.cfg"
}

resource "local_file" "pgbench_host_vars" {
  content = templatefile("templates/pgbench_host_vars.yml", {
    PGBENCH_PK = "./pgbench_pk.pem",
    PG_HOST     = length(aws_db_instance.demodb.*.address) > 0 ? aws_db_instance.demodb.*.address[0] : "none",
    PG_PORT     = length(aws_db_instance.demodb.*.port) > 0 ? aws_db_instance.demodb.*.port[0] : "none",
    PG_DB_NAME  = length(aws_db_instance.demodb.*.name) > 0 ? aws_db_instance.demodb.*.name[0] : "none",
    PG_USER     = length(aws_db_instance.demodb.*.username) > 0 ? aws_db_instance.demodb.*.username[0] : "none",
    PG_PWD      = random_password.demodb_password.result
  })
  filename = "out/host_vars/pgbench.yml"
}

resource "local_file" "pgbench_pb" {
  content  = file("templates/pgbench_pb.yml")
  filename = "out/pgbench_pb.yml"
}

resource "local_file" "endless_pgbench" {
  content = file("templates/endless_pgbench.sh")
  filename = "out/endless_pgbench.sh"
}