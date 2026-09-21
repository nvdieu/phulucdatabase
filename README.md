# Phu luc CSDL mau - Giao trinh Co so du lieu

Ma nguon tai lap cho Phu luc B cua giao trinh: 3 script SQL tao CSDL mau.

| File | Mo ta |
|---|---|
| `QLSinhVien.sql` | CSDL Quan ly Sinh vien (muc B.1) |
| `QLKhoHang.sql` | CSDL Quan ly Kho hang (muc B.2) |
| `QLDonDatHang.sql` | CSDL Quan ly Don dat hang (muc B.3) |
| `LICENSE.txt` | MIT License |
| `SHA256SUMS` | Checksum SHA-256 cua cac file .sql |

Script viet theo cu phap MySQL 8.0. Voi PostgreSQL: tao CSDL rieng roi ket noi
(`createdb X` roi `psql -d X -f script.sql`), bo `create database X; use X;`.

## Kiem tra checksum

    sha256sum -c SHA256SUMS          # Linux
    shasum -a 256 -c SHA256SUMS      # macOS
    CertUtil -hashfile QLSinhVien.sql SHA256   # Windows

## Kiem thu Chuong 3

Thu muc `kiemthu/` chua cac truy van cua Chuong 3 (Vi du 3.19, 3.55, 3.61 va cau 7, 9, 10, 16, 19, 20, 22, 24, 25, 26),
du lieu bien (diem NULL, dong hang, kho thieu/thua mat hang sai loai, giao hang nhieu dot, ban ghi giao khong thuoc don) va
ket qua thuc thi (`ketqua_thuc_thi.txt`). Chay: `bash kiemthu/chay_kiemthu.sh` hoac `bash kiemthu/chay_kiemthu.sh bien`.
