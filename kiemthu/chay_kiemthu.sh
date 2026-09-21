#!/bin/bash
# Chay kiem thu Chuong 3 tren MySQL 8.0 / MariaDB 10.x.
# Cach dung (trong thu muc goc cua kho): bash kiemthu/chay_kiemthu.sh [bien]
#   khong tham so : chay tren du lieu mau Phu luc B
#   tham so "bien": chay them du lieu bien (NULL, dong hang, ban ghi sai loai, ...)
# Can dang nhap duoc bang lenh "mysql" (them -u/-p vao bien MYSQL_OPTS neu can).
cd "$(dirname "$0")/.."
OPTS=${MYSQL_OPTS:-}
MODE="$1"
for p in "QLSinhVien T_SV" "QLKhoHang T_KHO" "QLDonDatHang T_DH"; do
  set -- $p
  mysql $OPTS -e "drop database if exists $2"
  sed "s/$1/$2/g" "$1.sql" | mysql $OPTS
done
if [ "$MODE" = "bien" ]; then mysql $OPTS < kiemthu/du_lieu_bien.sql; fi
mysql $OPTS -t < kiemthu/kiemthu_chuong3.sql
