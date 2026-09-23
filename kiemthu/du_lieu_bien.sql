use T_SV;
-- lop rong diem (diem NULL), lop dong hang voi C03 (GPA 7.5), sinh vien khong co dia chi, sinh vien trung ten 'Nguyễn Văn A'
insert into Class values ('C04','AI-2026','2026'), ('C05','DB-2026','2026');
insert into Student values ('T21','Diem Null','Q4','C04'), ('T22','Dong Hang','Q5','C05'), ('T23','Khong Diem',null,'C05');
insert into StudentGrade values ('T21','S01',null), ('T22','S01',7.5);
insert into Student values ('T24','Nguyễn Văn A','Q9','C01');
insert into StudentGrade values ('T24','S01',4.0), ('T24','S02',5.0);
use T_KHO;
insert into Category values ('C04','Rong');
insert into Warehouse values ('W04','Kho rong','C04'), ('W05','Kho sai loai','C01'), ('W06','Kho du va thua','C01'), ('W07','Kho dong hang','C01');
insert into Instock values ('W05','P01',20), ('W05','P03',20), ('W06','P01',1), ('W06','P02',1), ('W06','P03',1), ('W07','P01',800);
use T_DH;
insert into Customer values ('M03','Cong ty XYZ','1 Le Loi, Q1');
insert into Orders values ('R03','2026-09-01','2026-09-10','M03'), ('R04','2026-09-02','2026-09-12','M02'), ('R05','2026-09-03','2026-09-13','M02');
insert into OrdersDetail values ('R03','P01',38), ('R04','P01',2), ('R04','P02',1), ('R05','P03',4);
insert into Delivery values ('D02','2026-09-05','R04'), ('D03','2026-09-06','R05'), ('D04','2026-09-07','R05');
insert into DeliveryDetail values ('D01','P03',9), ('D02','P01',2), ('D02','P02',1), ('D03','P03',2), ('D04','P03',2);
