use T_SV;
insert into Class values ('C04','AI02','2026'), ('C05','DB05','2025');
insert into Student values ('T05','Diem Null','Q4',  'C04'), ('T06','Dong Hang','Q5','C05'), ('T07','Khong Diem',null,'C05');
insert into StudentGrade values ('T05','S01',null), ('T06','S01',8.0), ('T06','S02',8.75);
-- sinh vien trung ten 'Nguyen Van A'
insert into Student values ('T08','Nguyen Van A','Q9','C01');
insert into StudentGrade values ('T08','S01',4.0), ('T08','S02',5.0);
use T_KHO;
insert into Category values ('C04','Rong');
insert into Warehouse values ('W04','Kho rong','C04'), ('W05','Kho sai loai','C01'), ('W06','Kho du va thua','C01'), ('W07','Kho dong hang','C01');
insert into Instock values ('W05','P01',20), ('W05','P03',20), ('W06','P01',1), ('W06','P02',1), ('W06','P03',1), ('W07','P01',800);
use T_DH;
insert into Customer values ('M03','Cong ty XYZ','1 Le Loi, Q1');
insert into Orders values ('D03','2026-09-01','2026-09-10','M03'), ('D04','2026-09-02','2026-09-12','M02'), ('D05','2026-09-03','2026-09-13','M02');
insert into OrdersDetail values ('D03','P01',38), ('D04','P01',2), ('D04','P02',1), ('D05','P03',4);
insert into Delivery values ('G02','2026-09-05','D04'), ('G03','2026-09-06','D05'), ('G04','2026-09-07','D05');
insert into DeliveryDetail values ('G01','P03',9), ('G02','P01',2), ('G02','P02',1), ('G03','P03',2), ('G04','P03',2);
