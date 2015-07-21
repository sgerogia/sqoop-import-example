#!/bin/bash

hive_conf_dir="$1"
hive_server_host="$2"
hive_server_port="$3"

your_db_host="$4"
your_db_port="$5"
your_db_user="$6"
your_db_pwd="$7"

hivedbname="$8"

dbname="$9"
tablename="${10}"
mapcolumn="${11}"
splitby="${12}"
conditions="${13}"


export HIVE_CONF_DIR="${hive_conf_dir}"

# Create Hive DB in case this is the first time
beeline -u "jdbc:hive2://${hive_server_host}:${hive_server_port}" -e "CREATE DATABASE IF NOT EXISTS ${hivedbname} LOCATION '/hive-data/${hivedbname}'"

# Delete existing data
hadoop fs -rm -r "/hive-data/${hivedbname}/${tablename}"

# Assemble Sqoop options string
SQOOP_OPTIONS=(--connect \""jdbc:sqlserver://${your_db_host}:${your_db_port};database=${dbname};user=${your_db_user};password=${your_db_pwd}"\")

SQOOP_OPTIONS+=(--target-dir \""/hive-data/${hivedbname}/${tablename}"\")

if [ "${conditions}" == "" ]; then
  conditions="1=1"
fi

SQOOP_OPTIONS+=(--query \""select * from ${tablename} WHERE ${conditions} AND \$CONDITIONS"\")

if [ "${splitby}" != "" ]; then
  SQOOP_OPTIONS+=(--split-by \""${splitby}"\")
else
  SQOOP_OPTIONS+=(--num-mappers \"1\")
fi

if [ "${mapcolumn}" != "" ]; then
  SQOOP_OPTIONS+=(--map-column-java \""${mapcolumn}"\" --map-column-hive \""${mapcolumn}"\")
fi

SQOOP_OPTIONS+=(--hive-table \""${hivedbname}.${tablename}"\")

SQOOP_OPTIONS+=(--hive-import)

# ...and EXECUTE
echo "------- Executing Sqoop import. Table [${tablename}] --------"
echo "Sqoop options: ${SQOOP_OPTIONS[@]}"

/usr/bin/sqoop import "${SQOOP_OPTIONS[@]}" 1>/dev/null

echo "------- Sqoop import complete --------"

