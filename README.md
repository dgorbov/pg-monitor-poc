# PostgreSQL monitoring solution - proof of concept

Concept includes only part of the monitoring solution: AWS RDS PostgreSQL, DB parameter group with `pg_stat_statements` configured, ec2 instance with `postgres_exporter` and `pgBench`

## Reason
- Before we run monitoring solution on client's production envirment, we will use test data and test setup
- To mininise costs of poc maintanece we will turn on/off solution when it is needed plus we will use spot instances 

## Setup
### In case you need execute it first time on AWS account
1. Go to `backend_setup/`, review command parametrs (do not forget s3-buckets uniq name rule), run following command: `terraform apply -var 'AWS_REGION=eu-central-1' -var 'AWS_PROFILE=default' -var 'S3_BUCKET_NAME=pg-monitor-poc-terraform-state'`
2. Follow instruction bellow to connect your backend.
### In case you need execute it first time on your local environment and AWS part has been already setted up
1. Setup your `AWS_PROFILE` via aws_cli or via text editor inside `~/.aws` in `config` and `credentials` files
2. Configure backend: `terraform init -backend-config="bucket=pg-monitor-poc-terraform-state" -backend-config="region=eu-central-1" -backend-config="profile=default"`
3. change values of `profile`, `bucket` and `region` according to your initial backend configuration