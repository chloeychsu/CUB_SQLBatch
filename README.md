# SQLBatch 腳本批次執行

採用這種批次執行方式的主要目的是確保數據一致性、提升執行效率並簡化操作流程。以下是此方式的主要優勢：

1. 確保數據一致性<br>
   在資料庫操作中，數據一致性是極為重要的。此腳本將所有 SQL 檔案組合在一個交易中執行，確保在任何步驟發生錯誤時，可以進行自動回滾。這意味著，如果執行過程中出現錯誤，整個交易不會提交，所有的變更將恢復到執行前的狀態，避免資料庫部分更新的不一致情況。
   <br>
2. 減少手動操作錯誤<br>
   手動逐一執行多個 SQL 檔案，容易因順序錯誤或遺漏某些檔案而導致執行結果不符預期。此腳本會自動遍歷資料夾中的所有 .sql 檔案，並按順序批次執行。這樣可以減少手動操作的風險，避免因執行順序或疏忽而造成的錯誤，讓整個過程更加簡單可靠。
   <br>

3. 提高執行效率和可重複性<br>
   此腳本可以在多個環境中重複使用（如開發、測試、上線環境），只需將需要的 SQL 檔案放入指定資料夾中，即可自動完成批次執行。這不僅節省時間，也有助於保持環境間的一致性。在多次重複操作中，該腳本可確保執行過程一致、可靠且自動化，讓開發和測試過程更具效率。
   <br>

4. 支援回滾，降低風險<br>
   在批次執行過程中，難免會因為環境差異或資料問題導致某些 SQL 指令執行失敗。此腳本設置了自動回滾機制，當發生錯誤時，整個交易將自動回滾至初始狀態，確保資料庫無任何殘留問題。這樣可以降低操作風險，尤其是在操作生產環境時，回滾功能可為操作提供額外的保障。
   <br>

5. 清晰的執行流程和錯誤提示<br>
   此腳本設置了明確的日誌輸出，執行過程中會顯示每個 SQL 檔案的執行情況，並在發生錯誤時提供詳細的錯誤提示。這樣的錯誤提示不僅幫助快速定位問題，還便於後續的錯誤排查和修復，提升團隊之間的協作效率。

---

## 使用條件

- 操作系統：適用於 Linux 或 macOS (建議使用 docker 來實作)
- PostgreSQL 客戶端：需安裝 psql 命令行工具
  [安裝 psql 指令](https://www.postgresql.org/download/)
- 權限要求：執行腳本的使用者需具有足夠的資料庫操作權限

---

## 執行步驟

1. 將所有 SQL 指令檔案放入指定資料夾

   請將所有需要執行的 SQL 檔案放入一個指定的資料夾中，這些檔案的副檔名應為 .sql，並確保它們可以按照指定順序執行（如果有依賴關係，請按依賴順序命名，例如 01_create_table.sql, 02_insert_data.sql 等）。

2. 確認 `batch_sql_script.sh` 多個 sql 檔批次封裝 shell 腳本參數

   - SQL_DIR：SQL 檔案的目錄

     ```sh
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
     ```

3. 確認 `execute_sql_script.sh` sql 指令執行檔 Shell 腳本參數

   - DB_NAME：資料庫名稱
   - DB_USER：資料庫使用者名稱
   - DB_HOST：資料庫主機（本地測試時通常為 localhost）
   - DB_PORT：資料庫埠號（預設為 5432）

     ```sh
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
     ```

4. 設置的執行權限 (僅第一次執行)
   ```bash
   chmod +x execute_sql_scripts.sh
   ```
5. 執行
   ```bash
   # 批次包裝
   ./batch_sql_script.sh
   # 執行 SQL 指令（含 Rollback 功能）
   ./execute_sql_script.sh
   ```
