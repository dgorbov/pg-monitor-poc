resource "local_file" "exporter_pk" {
  content         = tls_private_key.exporter.private_key_pem
  filename        = "out/exporter_pk.pem"
  file_permission = 600
}

resource "local_file" "ansible_hosts" {
  content = templatefile("templates/ansible_hosts", {
    EXPORTER_IP = aws_spot_instance_request.exporter_instance.public_ip
  })
  filename = "out/hosts"
}

resource "local_file" "ansible_cfg" {
  content  = file("templates/ansible.cfg")
  filename = "out/ansible.cfg"
}

resource "local_file" "exporter_host_vars" {
  content = templatefile("templates/exporter_host_vars.yml", {
    EXPORTER_PK = "./exporter_pk.pem",
    PG_HOST     = length(aws_db_instance.demodb.*.address) > 0 ? aws_db_instance.demodb.*.address[0] : "none",
    PG_PORT     = length(aws_db_instance.demodb.*.port) > 0 ? aws_db_instance.demodb.*.port[0] : "none",
    PG_DB_NAME  = length(aws_db_instance.demodb.*.name) > 0 ? aws_db_instance.demodb.*.name[0] : "none",
    PG_USER     = length(aws_db_instance.demodb.*.username) > 0 ? aws_db_instance.demodb.*.username[0] : "none",
    PG_PWD      = random_password.demodb_password.result
  })
  filename = "out/host_vars/exporter.yml"
}

resource "local_file" "exporter_pb" {
  content  = file("templates/exporter_pb.yml")
  filename = "out/exporter_pb.yml"
}