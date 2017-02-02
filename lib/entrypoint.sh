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

sync_attr() {
  local sync=$1
  local attr=$2
  jq ".syncs[$sync].$attr" /media/bucardo/bucardo.json
}

add_databases_to_bucardo() {
  echo "[CONTAINER] Adding databases to Bucardo..."
  local db_id
  local db_index=0
  NUM_DBS=$(jq '.databases' /media/bucardo/bucardo.json | grep dbname | wc -l)
  while [[ $db_index -lt $NUM_DBS ]]; do
    echo "[CONTAINER] Adding db $db_index"
    db_id=$(db_attr $db_index id)
    run_bucardo_command "del db db$db_id --force"
    run_bucardo_command "add db db$db_id dbname=$(db_attr $db_index dbname) \
                                user=$(db_attr $db_index user) \
                                pass=$(db_attr $db_index pass) \
                                host=$(db_attr $db_index host)"
    db_index=$(expr $db_index + 1)
  done
}

db_sync_entities() {
  local sync_index=$1
  local entity=$2
  local db_index=0
  local sync_entity

  sync_entity=$(sync_attr $sync_index $entity"s[$db_index]")
  while [[ "$sync_entity" != null ]]; do
    [[ "$DB_STRING" != "" ]] && DB_STRING="$DB_STRING,"
    DB_STRING=$DB_STRING"db"$sync_entity":$entity"
    db_index=$(expr $db_index + 1)
    sync_entity=$(sync_attr $sync_index $entity"s[$db_index]")
  done
  }

db_sync_string() {
  local sync_index=$1
  DB_STRING=""
  db_sync_entities $sync_index "source"
  db_sync_entities $sync_index "target"
}

add_syncs_to_bucardo() {
  local sync_index=0
  local num_syncs=$(jq '.syncs' /media/bucardo/bucardo.json | grep tables | wc -l)
  while [[ $sync_index -lt $num_syncs ]]; do
    echo "[CONTAINER] Adding sync$sync_index to Bucardo..."
    db_sync_string $sync_index
    run_bucardo_command "del sync sync$sync_index"
    run_bucardo_command "add sync sync$sync_index \
                         dbs=$DB_STRING \
                         tables=$(sync_attr $sync_index tables)"
    sync_index=$(expr $sync_index + 1)
  done
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
  add_syncs_to_bucardo
  start_bucardo
  bucardo_status
}

main
