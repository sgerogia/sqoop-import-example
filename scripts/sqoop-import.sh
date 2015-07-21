#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

TABLES_FILE="$DIR/tables.txt"

# ----- Environment vars -----
# Review and change the values below for your environment

HIVE_CONF_DIR="/etc/hive/conf"

HIVE_HOST="localhost"
HIVE_PORT="10000"

HIVE_DB_NAME="raw"

YOUR_DB_HOST="DBHOST"
YOUR_DB_PORT="1234"
YOUR_DB_USER="test-user"
YOUR_DB_PWD="test-pwd"

# ----- EOF Environment vars -----


while IFS=$'|' read -r -a columns
do
   # Ignore comments and empty lines
   if [[ "$(echo -e "${columns[0]}" | tr -d '[[:space:]]')" == '' || ${columns[0]:0:1} == '#' ]]; then
      continue
   fi

  # Pass static and dynamic variables trimming white space
  $DIR/import.sh \
        "$HIVE_CONF_DIR" \
        "$HIVE_HOST" \
        "$HIVE_PORT" \
        "$YOUR_DB_HOST" \
        "$YOUR_DB_PORT" \
        "$YOUR_DB_USER" \
        "$YOUR_DB_PWD" \
        "$HIVE_DB_NAME" \
        "$(echo -e "${columns[0]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')" \
        "$(echo -e "${columns[1]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')" \
        "$(echo -e "${columns[2]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')" \
        "$(echo -e "${columns[3]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')" \
        "$(echo -e "${columns[4]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
done < "$TABLES_FILE"

