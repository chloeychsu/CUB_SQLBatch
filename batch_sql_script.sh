#!/bin/bash

# SQL 檔案的目錄
SQL_DIR="./sample-sql"        

# 建立一個臨時 SQL 文件，用於批次執行
TEMP_SQL="temp_execute.sql"

# 開始建立交易 SQL，使用 BEGIN 開始一個交易
echo "BEGIN;" > $TEMP_SQL

# 將資料夾中的所有 SQL 檔案附加到 TEMP_SQL
for sql_file in "$SQL_DIR"/*.sql; do
    if [[ -f $sql_file ]]; then
        echo "-- 執行檔案: $sql_file" >> $TEMP_SQL
        cat "$sql_file" >> $TEMP_SQL
        echo -e "\n" >> $TEMP_SQL
    fi
done

# 在 TEMP_SQL 的最後加入 COMMIT，完成交易
echo "COMMIT;" >> $TEMP_SQL


