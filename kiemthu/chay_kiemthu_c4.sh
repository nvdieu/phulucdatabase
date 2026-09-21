#!/bin/bash
# Chay kiem thu Chuong 4 (trigger: vi pham, rollback, xung dot dong thoi).
# Cach dung (trong thu muc goc cua kho):
#   bash kiemthu/chay_kiemthu_c4.sh mysql      # MySQL 8.0 / MariaDB 10.x  (MYSQL_OPTS="-u root -p..." neu can)
#   bash kiemthu/chay_kiemthu_c4.sh postgres   # PostgreSQL 16              (PSQL_OPTS="-U user -d db" neu can)
cd "$(dirname "$0")"
case "$1" in
  mysql)    mysql ${MYSQL_OPTS:-} --default-character-set=utf8mb4 --force -t < chuong4_mysql.sql 2>&1 | grep -v '^[+-]'
            echo; echo "### XUNG DOT DONG THOI (MySQL)"; bash chuong4_dongthoi.sh mysql ;;
  postgres) psql ${PSQL_OPTS:--U root -d postgres} -q -t -A -f chuong4_postgres.sql 2>&1 | grep -v '^$' | grep -v 'CONTEXT'
            echo; echo "### XUNG DOT DONG THOI (PostgreSQL)"; bash chuong4_dongthoi.sh postgres ;;
  *) echo "Cach dung: bash $0 mysql|postgres" ;;
esac
