# Script to run over corrupted postgres tables to find which offsets are broken
# For large tables it can take very long time so it's good to run the script with '&' added

#!/bin/sh

j=0
failed_offsets="failed_offsets.txt"

db_user="postgres"
db_name="postgres"
table_name="table_name"

> "$failed_offsets"

while [ $j -lt 2249780 ]
do
  psql -U $db_user -d $db_name -c "SELECT * FROM $table_name LIMIT 1 OFFSET $j" >/dev/null

  if [ $? -ne 0 ]; then
    echo "Error at offset $j" >> "$failed_offsets"
  fi

  j=$(($j + 1))

  if [ $(($j % 100)) -eq 0 ]; then
    echo "Processed $j offsets..."
  fi
done

echo "Completed processing all rows."

if [ -s "$failed_offsets" ]; then
  echo "Failed offsets:"
  cat "$failed_offsets"
else
  echo "No failures detected."
fi
