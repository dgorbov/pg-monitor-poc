#!/bin/bash

# script requires these environment variables to be set
# export PGHOST=$1
# export PGPORT=$2
# export PGDATABASE=$3
# export PGUSER=$4
# export PGPASSWORD=$5

function check_pgbench_tables() {
  psql --set 'ON_ERROR_STOP=' <<-EOSQL
    DO \$\$
      DECLARE
        pgbench_tables CONSTANT text[] := '{ "pgbench_branches", "pgbench_tellers", "pgbench_accounts", "pgbench_history" }';
        tbl text;
      BEGIN
        FOREACH tbl IN ARRAY pgbench_tables LOOP
          IF NOT EXISTS (
            SELECT 1
            FROM pg_catalog.pg_class c
            JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
            WHERE n.nspname = 'public'
            AND c.relname = tbl
            AND c.relkind = 'r'
          ) THEN 
            RAISE EXCEPTION 'pgbench table "%" does not exist!', tbl;
          END IF;
        END LOOP;
      END 
    \$\$;
EOSQL
  psql_status=$?
  
  case $psql_status in
    0) echo "All pgbench tables exist! We can begin the benchmark" ;;
    1) echo "psql encountered a fatal error!" ;;
    2) echo "psql encountered a connection error!" ;;
    3) echo "One or more tables was missing! Initializing the database.";;
  esac

  return $psql_status
}

function initialize_pgbench_tables() {
  echo "Initializing pgbench tables"
  pgbench -i -s 150 --foreign-keys
}

check_pgbench_tables

if [[ $? -eq 3 ]]; then
  initialize_pgbench_tables
fi

echo "run pgbench for 1 year and use only SELECT statement to avoid DB running out of disc space"
pgbench -c 50 -j 1 -P 60 -T 525600 -S