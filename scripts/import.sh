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
tablename="${10,,}" # to lower-case
javamapcolumn="${11}"
splitby="${12}"
conditions="${13}"

###
# Split the comma-separated java-typed columns and constructs Hive-typed equivalent, if necessary
###
function convertJavaToHiveType() {
   # split on commas
   local columns=""
   IFS=',' read -ra columns <<< "$1"

   convertJavaToHiveType_result=""

   for col in "${columns[@]}"; do

       case "$col" in

          *Integer)
            convertJavaToHiveType_result="${convertJavaToHiveType_result},${col%=*}=INT"
            ;;
          *Long)
            convertJavaToHiveType_result="${convertJavaToHiveType_result},${col%=*}=LONG"
            ;;
          *Float)
            convertJavaToHiveType_result="${convertJavaToHiveType_result},${col%=*}=FLOAT"
            ;;
          *Double)
            convertJavaToHiveType_result="${convertJavaToHiveType_result},${col%=*}=DOUBLE"
            ;;
          *Boolean)
            convertJavaToHiveType_result="${convertJavaToHiveType_result},${col%=*}=BOOLEAN"
            ;;
          *String)
            convertJavaToHiveType_result="${convertJavaToHiveType_result},${col%=*}=STRING"
            ;;
          # All date types are treated the same
          *Date)
            ;&
          *Time)
            ;&
          *Timestamp)
            convertJavaToHiveType_result="${convertJavaToHiveType_result},${col%=*}=TIMESTAMP"
            ;;
          *BigDecimal)
            convertJavaToHiveType_result="${convertJavaToHiveType_result},${col%=*}=DECIMAL"
            ;;
          # BLOBs are treated the same
          *ClobRef)
             ;&
          *BlobRef)
             # Keep the column name, replace data type with '=BINARY' (variable expansion) and append
             convertJavaToHiveType_result="${convertJavaToHiveType_result},${col%=*}=BINARY"
             ;;
          *)
             # Other cases, do nothing
             ;;
       esac
   done

   # return and get rid of leading comma
   echo "${convertJavaToHiveType_result:1}"
}


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

SQOOP_OPTIONS+=(--inline-lob-limit \"0\")

if [ "${splitby}" != "" ]; then
  SQOOP_OPTIONS+=(--split-by \""${splitby}"\")
else
  SQOOP_OPTIONS+=(--num-mappers \"1\")
fi

if [ "${javamapcolumn}" != "" ]; then
  SQOOP_OPTIONS+=(--map-column-java \""${javamapcolumn}"\")

  hivemapcolumn="$(convertJavaToHiveType "${javamapcolumn}")"

  if [ "${hivemapcolumn}" != '' ]; then
      SQOOP_OPTIONS+=(--map-column-hive \""${hivemapcolumn}"\")
  fi
fi

SQOOP_OPTIONS+=(--hive-table \""${hivedbname}.${tablename}"\")

SQOOP_OPTIONS+=(--hive-import)

# ...and EXECUTE
echo "------- Executing Sqoop import. Table [${tablename}] --------"
echo "Sqoop options: ${SQOOP_OPTIONS[@]}"

/usr/bin/sqoop import "${SQOOP_OPTIONS[@]}" &> "./sqoop-import-${tablename}.log"

echo "------- Sqoop import complete --------"

