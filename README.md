# PostgreSQL monitoring solution - proof of concept

Concept includes only part of the monitoring solution: AWS RDS PostgreSQL, DB parameter group with `pg_stat_statements` configured, ec2 instance with `pgBench`

## Reason
- Before we run monitoring solution on client's production envirment, we will use test data and test setup
- To mininise costs of poc maintanece we will turn on/off solution when it is needed plus we will use spot instances 

## Setup
### Software requirements
1. `Terraform v0.12.12` and above
2. `Ansible 2.9.2` and above

### Setup S3 backend
1. https://github.com/dgorbov/terraform-s3-backend-setup
2. `terraform init -backend-config="bucket=***" -backend-config="dynamodb_table=***" -backend-config="region=eu-central-1" -backend-config="profile=default"`

### Specify defaults values in `terraform.tfvars`
```
create_db    = true
allowed_cidr = ["XXX.XXX.XXX.XXX/32"]
pgbench_instance_cfg = {
  spot_price    = 0.0018
  instance_type = "t3.nano"
}
```
### Run project with following commands
1. `terraform apply`
2. `cd out`
3. `ansible-playbook pgbench_pb.yml`