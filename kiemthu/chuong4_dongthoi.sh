#!/bin/bash
# KIEM THU XUNG DOT DONG THOI (Chuong 4) - rang buoc suc chua kho: tong Quantity <= MaxCapacity (=50)
# Hai giao dich A va B cung them 30 don vi vao kho W03 (moi giao dich rieng le deu hop le, cong lai = 60 > 50).
# Chay: bash kiemthu/chuong4_dongthoi.sh mysql | postgres
# Ket qua mong doi: xem cuoi moi kich ban (tong_ton_kho > 50 nghia la RANG BUOC BI VI PHAM).
MY="${MYSQL_OPTS:-}"; PG="${PSQL_OPTS:--U root -d postgres}"

mysql_setup() {  # $1 = 'khoa' | 'khong_khoa'
  local LOCK=""; [ "$1" = "khoa" ] && LOCK=" for update"
  mysql $MY --default-character-set=utf8mb4 <<SQL
drop database if exists T_C4C; create database T_C4C; use T_C4C;
create table Warehouse (WarehouseID char(3) primary key, MaxCapacity int);
create table Instock (WarehouseID char(3), ProductID char(3), Quantity int, primary key (WarehouseID, ProductID));
insert into Warehouse values ('W03', 50);
delimiter //
create trigger kt_succhua_ins before insert on Instock for each row
begin
  declare v_max int; declare v_sum int;
  select MaxCapacity into v_max from Warehouse where WarehouseID = new.WarehouseID$LOCK;
  select coalesce(sum(Quantity),0) into v_sum from Instock where WarehouseID = new.WarehouseID;
  if v_sum + new.Quantity > v_max then signal sqlstate '45000' set message_text = 'Vuot suc chua'; end if;
end //
delimiter ;
SQL
}
mysql_scenario() {  # $1 = tieu de, $2 = 'khoa'|'khong_khoa', $3 = muc co lap, $4 = B co doc truoc khi ghi (0/1)
  echo "--- $1"
  mysql_setup $2
  ( mysql $MY T_C4C -e "set session transaction isolation level $3; start transaction; insert into Instock values ('W03','P01',30); do sleep(3); commit;" 2>&1 | sed 's/^/  A: /' ) &
  sleep 1
  local PRE=""; [ "$4" = "1" ] && PRE="select count(*) from Instock;"
  ( mysql $MY T_C4C -e "set session transaction isolation level $3; start transaction; $PRE insert into Instock values ('W03','P02',30); commit;" 2>&1 | grep -v "^count" | grep -v '^[0-9]*$' | sed 's/^/  B: /' ) &
  wait
  echo -n "  => tong_ton_kho W03 = "; mysql $MY T_C4C -N -e "select coalesce(sum(Quantity),0) from Instock"
}

pg_setup() {  # $1 = 'khoa' | 'khong_khoa'
  local LOCK=""; [ "$1" = "khoa" ] && LOCK="for update"
  psql $PG -q <<SQL
set client_min_messages = warning;
drop schema if exists t_c4c cascade; create schema t_c4c; set search_path = t_c4c;
create table Warehouse (WarehouseID char(3) primary key, MaxCapacity int);
create table Instock (WarehouseID char(3), ProductID char(3), Quantity int, primary key (WarehouseID, ProductID));
insert into Warehouse values ('W03', 50);
create function kt_succhua() returns trigger as \$\$
declare v_max int; v_sum int;
begin
  select MaxCapacity into v_max from Warehouse where WarehouseID = new.WarehouseID $LOCK;
  select coalesce(sum(Quantity),0) into v_sum from Instock where WarehouseID = new.WarehouseID;
  if v_sum + new.Quantity > v_max then raise exception 'Vuot suc chua'; end if;
  return new;
end; \$\$ language plpgsql;
create trigger trg before insert on Instock for each row execute function kt_succhua();
SQL
}
pg_scenario() {  # $1 = tieu de, $2 = khoa|khong_khoa, $3 = muc co lap, $4 = B doc truoc (0/1)
  echo "--- $1"
  pg_setup $2
  ( psql $PG -q -c "set search_path = t_c4c" -c "begin isolation level $3" -c "insert into Instock values ('W03','P01',30)" -c "select pg_sleep(3)" -o /dev/null -c "commit" 2>&1 | grep -i "error" | sed 's/^/  A: /' ) &
  sleep 1
  local PRE="select 1"; [ "$4" = "1" ] && PRE="select count(*) from Instock"
  ( psql $PG -q -c "set search_path = t_c4c" -c "begin isolation level $3" -c "$PRE" -c "insert into Instock values ('W03','P02',30)" -c "commit" 2>&1 | grep -i "error" | sed 's/^/  B: /' ) &
  wait
  echo -n "  => tong_ton_kho W03 = "; psql $PG -q -t -A -c "select coalesce(sum(Quantity),0) from t_c4c.Instock"
}

case "$1" in
mysql)
  mysql_scenario "K1. Trigger KHONG khoa dong kho (REPEATABLE READ mac dinh): ca hai qua duoc -> VI PHAM" khong_khoa "repeatable read" 0
  mysql_scenario "K2. Trigger co khoa dong kho (for update), B chua doc gi truoc: B cho A commit roi bi tu choi" khoa "repeatable read" 0
  mysql_scenario "K3. Nhu K2 nhung B da doc bang Instock truoc do (snapshot cu) o REPEATABLE READ: van co the VI PHAM" khoa "repeatable read" 1
  mysql_scenario "K4. Nhu K3 nhung dung READ COMMITTED: B thay du lieu da commit cua A -> bi tu choi" khoa "read committed" 1
  ;;
postgres)
  pg_scenario "K1. Trigger KHONG khoa dong kho (READ COMMITTED mac dinh): ca hai qua duoc -> VI PHAM" khong_khoa "read committed" 0
  pg_scenario "K2. Trigger co khoa dong kho (for update), READ COMMITTED: B cho A commit roi bi tu choi" khoa "read committed" 0
  pg_scenario "K3. Khoa dong kho + REPEATABLE READ, B da doc truoc: van co the VI PHAM (snapshot cu)" khoa "repeatable read" 1
  pg_scenario "K4. SERIALIZABLE, B da doc truoc: PostgreSQL huy giao dich (serialization failure), khong vi pham" khong_khoa "serializable" 1
  ;;
*) echo "Cach dung: bash $0 mysql|postgres";;
esac
