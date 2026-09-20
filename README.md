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
