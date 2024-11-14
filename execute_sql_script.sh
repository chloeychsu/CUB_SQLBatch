#!/bin/bash

# 設定 PostgreSQL 連接參數
DB_NAME="testdb"       
DB_USER="sa"       
DB_HOST="localhost"
DB_PORT="5432"

# SQL 檔案的目錄
SQL_DIR="./sample-sql"        

# 建立一個臨時 SQL 文件，用於批次執行
TEMP_SQL="temp_execute.sql"

# 使用 psql 執行 TEMP_SQL，並自動回滾交易如有錯誤發生
psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -f $TEMP_SQL -v ON_ERROR_STOP=1 || {
    echo "發生錯誤，正在回滾交易..."
    psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -c "ROLLBACK;"
}

# 刪除臨時 SQL 文件
rm -f $TEMP_SQL
