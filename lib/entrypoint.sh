#/bin/bash

# Entrypoint Script
# Author: Lucas Vieira < lucas at vieira dot io >
# Version: 1.0
# January 31th, 2017

# ~ #

run_bucardo_command() {
  local comm=$1
  su - postgres -c "bucardo $comm"
}

start_postgres() {
  service postgresql start
  local status=false
  while [[ $status == false ]]; do
    [[ $(run_bucardo_command "status") ]] && status=true
    sleep 5
  done
}

db_attr() {
  local database=$1
  local attr=$2
  jq ".databases[$database].$attr" /media/bucardo/bucardo.json
}

add_databases_to_bucardo() {
  echo "[CONTAINER] Adding databases to Bucardo..."
  local db_index=0
  NUM_DBS=$(jq '.databases' /media/bucardo/bucardo.json | grep dbname | wc -l)
  while [[ $db_index -lt $NUM_DBS ]]; do
    echo "[CONTAINER] Adding db $db_index"
    run_bucardo_command "add db db$db_index dbname=$(db_attr $db_index dbname) \
                                user=$(db_attr $db_index user) \
                                pass=$(db_attr $db_index pass) \
                                host=$(db_attr $db_index host)"
    db_index=$(expr $db_index + 1)
  done
}

add_sync_to_bucardo() {
  echo "[CONTAINER] Adding sync to Bucardo..."
  run_bucardo_command "add sync sync0 \
                       dbs=db0,db1 \
                       tables=$(jq '.tables' /media/bucardo/bucardo.json)"
}

start_bucardo() {
  echo "[CONTAINER] Starting Bucardo..."
  run_bucardo_command "start"
}

bucardo_status() {
  echo "[CONTAINER] Now, some status for you."
  local run=true
  while [[ $run ]]; do
    run_bucardo_command "status"
    sleep 10
  done
}

main() {
  start_postgres 2> /dev/null
  add_databases_to_bucardo
  add_sync_to_bucardo
  start_bucardo
  bucardo_status
}

main
