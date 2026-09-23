-- KIEM THU CHUONG 4 - MySQL 8.0 / MariaDB 10.x
-- Chay: bash kiemthu/chay_kiemthu_c4.sh mysql   (chay voi mysql --force de tiep tuc sau khi gap loi)
-- Nhan [OK] = thao tac hop le duoc chap nhan; [PHAI LOI] = thao tac vi pham, trigger phai tu choi (se thay ERROR 1644).

-- ============ PHAN A: Rang buoc ngay giao >= ngay dat (Vi du 4.7, 3 trigger) ============
create database if not exists T_C4A; drop database T_C4A; create database T_C4A; use T_C4A;
create table Customer (CustomerID char(3) primary key, CustomerName varchar(30) not null, CustomerAddress varchar(30));
create table Orders (
  OrdersID char(3) primary key, OrdersDate date not null, RequiredDate date, CustomerID char(3),
  foreign key (CustomerID) references Customer(CustomerID), check (RequiredDate >= OrdersDate));
create table Delivery (
  DeliveryID char(3) primary key, DeliveryDate date, OrdersID char(3),
  foreign key (OrdersID) references Orders(OrdersID));

delimiter //
create trigger kt_ngaygiao_ins before insert on Delivery for each row
begin
  declare v_OrdersDate date;
  select OrdersDate into v_OrdersDate from Orders where OrdersID = new.OrdersID;
  if new.DeliveryDate < v_OrdersDate then
    signal sqlstate '45000' set message_text = 'Ngày giao phải bằng hoặc sau ngày đặt hàng';
  end if;
end //
create trigger kt_ngaygiao_upd before update on Delivery for each row
begin
  declare v_OrdersDate date;
  select OrdersDate into v_OrdersDate from Orders where OrdersID = new.OrdersID;
  if new.DeliveryDate < v_OrdersDate then
    signal sqlstate '45000' set message_text = 'Ngày giao phải bằng hoặc sau ngày đặt hàng';
  end if;
end //
create trigger kt_ngaydat_upd before update on Orders for each row
begin
  declare v_MinDeliveryDate date;
  if new.OrdersDate <> old.OrdersDate then
    select min(DeliveryDate) into v_MinDeliveryDate from Delivery where OrdersID = new.OrdersID;
    if v_MinDeliveryDate is not null and new.OrdersDate > v_MinDeliveryDate then
      signal sqlstate '45000' set message_text = 'Ngày đặt hàng mới trễ hơn đợt giao đã có';
    end if;
  end if;
end //
delimiter ;

insert into Customer values ('M01','Cong ty ABC',null);
insert into Orders values ('R01','2026-08-01','2026-08-10','M01'), ('R02','2026-08-15','2026-08-20','M01'), ('R03','2026-09-01','2026-09-05','M01');
insert into Delivery values ('D01','2026-08-08','R01');

select '[OK] A1 them dot giao hop le (giao sau ngay dat)' as test;
insert into Delivery values ('D02','2026-08-16','R02');
select '[OK] A2 giao dung ngay dat (bien: bang nhau)' as test;
insert into Delivery values ('D03','2026-09-01','R03');
select '[PHAI LOI] A3 them dot giao truoc ngay dat' as test;
insert into Delivery values ('D04','2026-08-14','R02');
select '[PHAI LOI] A4 sua ngay giao D01 ve truoc ngay dat cua R01' as test;
update Delivery set DeliveryDate = '2026-07-01' where DeliveryID = 'D01';
select '[PHAI LOI] A5 chuyen D01 sang don R02 (dat 2026-08-15, giao 2026-08-08)' as test;
update Delivery set OrdersID = 'R02' where DeliveryID = 'D01';
select '[PHAI LOI] A6 doi ngay dat R01 thanh 2026-08-20 (sau ngay giao 2026-08-08)' as test;
update Orders set OrdersDate = '2026-08-20' where OrdersID = 'R01';
select '[OK] A7 doi ngay dat R01 thanh 2026-08-05 (van truoc ngay giao)' as test;
update Orders set OrdersDate = '2026-08-05' where OrdersID = 'R01';
select '[OK] A8 don chua co dot giao thi doi ngay dat tu do' as test;
delete from Delivery where DeliveryID = 'D03';
update Orders set OrdersDate = '2026-09-03' where OrdersID = 'R03';
select 'A9 ket qua sau cac thao tac tren' as test;
select DeliveryID, DeliveryDate, OrdersID from Delivery order by 1;
select OrdersID, OrdersDate from Orders order by 1;

select 'A10 ROLLBACK: mot giao dich co thao tac hop le roi thao tac vi pham, sau do rollback' as test;
select count(*) as so_dot_giao_truoc from Delivery;
start transaction;
insert into Delivery values ('D05','2026-08-17','R02');
insert into Delivery values ('D06','2026-08-01','R02');   -- vi pham -> ERROR, giao dich van mo
select count(*) as so_dot_giao_trong_giao_dich from Delivery;
rollback;
select count(*) as so_dot_giao_sau_rollback from Delivery;

-- ============ PHAN B: Suc chua kho (tong Quantity <= MaxCapacity) ============
drop database if exists T_C4B; create database T_C4B; use T_C4B;
create table Category (CategoryID char(3) primary key, CategoryName varchar(30) not null);
create table Product (ProductID char(3) primary key, ProductName varchar(30) not null, UnitPrice float check (UnitPrice > 0),
  CategoryID char(3), foreign key (CategoryID) references Category(CategoryID));
create table Warehouse (WarehouseID char(3) primary key, WarehouseAddress varchar(30), CategoryID char(3), MaxCapacity int check (MaxCapacity >= 0),
  foreign key (CategoryID) references Category(CategoryID));
create table Instock (WarehouseID char(3), ProductID char(3), Quantity int check (Quantity >= 0),
  primary key (WarehouseID, ProductID),
  foreign key (WarehouseID) references Warehouse(WarehouseID), foreign key (ProductID) references Product(ProductID));

delimiter //
-- Insert va Update tren Instock: khoa dong Warehouse (for update) de cac giao dich cung ghi mot kho xep hang tuan tu,
-- roi moi tinh tong. (MySQL/MariaDB khong cho SELECT ... FOR UPDATE tren chinh bang Instock ben trong trigger cua no: loi 1442.)
create trigger kt_succhua_ins before insert on Instock for each row
begin
  declare v_max int; declare v_sum int;
  select MaxCapacity into v_max from Warehouse where WarehouseID = new.WarehouseID for update;
  select coalesce(sum(Quantity), 0) into v_sum from Instock where WarehouseID = new.WarehouseID;
  if v_max is not null and v_sum + new.Quantity > v_max then
    signal sqlstate '45000' set message_text = 'Vuot suc chua toi da cua kho';
  end if;
end //
create trigger kt_succhua_upd before update on Instock for each row
begin
  declare v_max int; declare v_sum int;
  select MaxCapacity into v_max from Warehouse where WarehouseID = new.WarehouseID for update;
  -- tong cua cac dong KHAC trong kho dich (loai dong dang sua), cong voi so luong moi
  select coalesce(sum(Quantity), 0) into v_sum from Instock
   where WarehouseID = new.WarehouseID and not (WarehouseID = old.WarehouseID and ProductID = old.ProductID);
  if v_max is not null and v_sum + new.Quantity > v_max then
    signal sqlstate '45000' set message_text = 'Vuot suc chua toi da cua kho';
  end if;
end //
-- Update tren Warehouse: ha suc chua xuong duoi tong ton hien co cung la vi pham
create trigger kt_succhua_kho_upd before update on Warehouse for each row
begin
  declare v_sum int;
  if new.MaxCapacity is not null and (old.MaxCapacity is null or new.MaxCapacity < old.MaxCapacity) then
    select coalesce(sum(Quantity), 0) into v_sum from Instock where WarehouseID = new.WarehouseID;
    if v_sum > new.MaxCapacity then
      signal sqlstate '45000' set message_text = 'Suc chua moi nho hon tong ton hien co';
    end if;
  end if;
end //
delimiter ;

insert into Category values ('C01','Nong san');
insert into Product values ('P01','Gao ST25',25000,'C01'), ('P02','Ca phe',80000,'C01');
insert into Warehouse values ('W01','Kho 1','C01',100), ('W02','Kho 2','C01',50);
insert into Instock values ('W01','P01',60), ('W01','P02',30);

select '[OK] B1 them ton kho hop le (W02, suc chua 50: them P01 x10)' as test;
insert into Instock values ('W02','P01',10);
select '[OK] B1b UPDATE tang len dung bang suc chua (W02 P01: 10 -> 50)' as test;
update Instock set Quantity = 50 where WarehouseID = 'W02' and ProductID = 'P01';
select '[PHAI LOI] B2 them ton kho vuot suc chua (W02 dang 50, them P02 x1)' as test;
insert into Instock values ('W02','P02',1);
select '[PHAI LOI] B3 UPDATE tang so luong lam W01 vuot 100 (P01 60 -> 71)' as test;
update Instock set Quantity = 71 where WarehouseID = 'W01' and ProductID = 'P01';
select '[OK] B4 UPDATE giu nguyen tong (W01: P01 60 -> 70, cong P02 30 = 100 = suc chua)' as test;
update Instock set Quantity = 70 where WarehouseID = 'W01' and ProductID = 'P01';
select '[PHAI LOI] B5 UPDATE chuyen dong sang kho khac lam vuot (P02 cua W01 chuyen sang W02 dang 50)' as test;
update Instock set WarehouseID = 'W02' where WarehouseID = 'W01' and ProductID = 'P02';
select '[PHAI LOI] B6 ha suc chua W01 xuong 90 trong khi dang chua 100' as test;
update Warehouse set MaxCapacity = 90 where WarehouseID = 'W01';
select '[OK] B7 tang suc chua W01 len 120' as test;
update Warehouse set MaxCapacity = 120 where WarehouseID = 'W01';
select 'B8 ket qua' as test;
select * from Instock order by 1,2;
select WarehouseID, MaxCapacity from Warehouse order by 1;
