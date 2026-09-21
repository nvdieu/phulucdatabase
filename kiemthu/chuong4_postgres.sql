-- KIEM THU CHUONG 4 - PostgreSQL 16
-- Chay: bash kiemthu/chay_kiemthu_c4.sh postgres   (psql khong dung khi gap loi: ON_ERROR_STOP=off)
\set ON_ERROR_STOP off
\pset pager off

-- ============ PHAN A: Rang buoc ngay giao >= ngay dat (Vi du 4.7, 3 trigger, 2 ham) ============
drop schema if exists t_c4a cascade; create schema t_c4a; set search_path = t_c4a;
create table Customer (CustomerID char(3) primary key, CustomerName varchar(30) not null, CustomerAddress varchar(30));
create table Orders (
  OrdersID char(3) primary key, OrdersDate date not null, RequiredDate date, CustomerID char(3) references Customer(CustomerID),
  check (RequiredDate >= OrdersDate));
create table Delivery (DeliveryID char(3) primary key, DeliveryDate date, OrdersID char(3) references Orders(OrdersID));

create or replace function kt_ngaygiao() returns trigger as $$
declare v_OrdersDate date;
begin
  select OrdersDate into v_OrdersDate from Orders where OrdersID = new.OrdersID;
  if new.DeliveryDate < v_OrdersDate then
    raise exception 'Ngày giao phải bằng hoặc sau ngày đặt hàng';
  end if;
  return new;
end;
$$ language plpgsql;
create trigger trg_kt_ngaygiao_ins before insert on Delivery for each row execute function kt_ngaygiao();
create trigger trg_kt_ngaygiao_upd before update on Delivery for each row execute function kt_ngaygiao();

create or replace function kt_ngaydat() returns trigger as $$
declare v_MinDeliveryDate date;
begin
  if new.OrdersDate <> old.OrdersDate then
    select min(DeliveryDate) into v_MinDeliveryDate from Delivery where OrdersID = new.OrdersID;
    if v_MinDeliveryDate is not null and new.OrdersDate > v_MinDeliveryDate then
      raise exception 'Ngày đặt hàng mới trễ hơn đợt giao đã có';
    end if;
  end if;
  return new;
end;
$$ language plpgsql;
create trigger trg_kt_ngaydat before update on Orders for each row execute function kt_ngaydat();

insert into Customer values ('M01','Cong ty ABC',null);
insert into Orders values ('D01','2026-08-01','2026-08-10','M01'), ('D02','2026-08-15','2026-08-20','M01'), ('D03','2026-09-01','2026-09-05','M01');
insert into Delivery values ('G01','2026-08-08','D01');

select '[OK] A1 them dot giao hop le (giao sau ngay dat)' as test;
insert into Delivery values ('G02','2026-08-16','D02');
select '[OK] A2 giao dung ngay dat (bien: bang nhau)' as test;
insert into Delivery values ('G03','2026-09-01','D03');
select '[PHAI LOI] A3 them dot giao truoc ngay dat' as test;
insert into Delivery values ('G04','2026-08-14','D02');
select '[PHAI LOI] A4 sua ngay giao G01 ve truoc ngay dat cua D01' as test;
update Delivery set DeliveryDate = '2026-07-01' where DeliveryID = 'G01';
select '[PHAI LOI] A5 chuyen G01 sang don D02 (dat 2026-08-15, giao 2026-08-08)' as test;
update Delivery set OrdersID = 'D02' where DeliveryID = 'G01';
select '[PHAI LOI] A6 doi ngay dat D01 thanh 2026-08-20 (sau ngay giao 2026-08-08)' as test;
update Orders set OrdersDate = '2026-08-20' where OrdersID = 'D01';
select '[OK] A7 doi ngay dat D01 thanh 2026-08-05 (van truoc ngay giao)' as test;
update Orders set OrdersDate = '2026-08-05' where OrdersID = 'D01';
select '[OK] A8 don chua co dot giao thi doi ngay dat tu do' as test;
delete from Delivery where DeliveryID = 'G03';
update Orders set OrdersDate = '2026-09-03' where OrdersID = 'D03';
select 'A9 ket qua sau cac thao tac tren' as test;
select DeliveryID, DeliveryDate, OrdersID from Delivery order by 1;
select OrdersID, OrdersDate from Orders order by 1;

select 'A10 ROLLBACK: trong PostgreSQL, loi lam giao dich chuyen sang trang thai loi, buoc phai rollback toan bo' as test;
select count(*) as so_dot_giao_truoc from Delivery;
begin;
insert into Delivery values ('G05','2026-08-17','D02');
insert into Delivery values ('G06','2026-08-01','D02');   -- vi pham -> ERROR, giao dich bi huy (aborted)
select count(*) as so_dot_giao_trong_giao_dich_loi from Delivery;  -- bi tu choi: current transaction is aborted
rollback;
select count(*) as so_dot_giao_sau_rollback from Delivery;

-- ============ PHAN B: Suc chua kho ============
drop schema if exists t_c4b cascade; create schema t_c4b; set search_path = t_c4b;
create table Category (CategoryID char(3) primary key, CategoryName varchar(30) not null);
create table Product (ProductID char(3) primary key, ProductName varchar(30) not null, UnitPrice float check (UnitPrice > 0),
  CategoryID char(3) references Category(CategoryID));
create table Warehouse (WarehouseID char(3) primary key, WarehouseAddress varchar(30), CategoryID char(3) references Category(CategoryID),
  MaxCapacity int check (MaxCapacity >= 0));
create table Instock (WarehouseID char(3) references Warehouse(WarehouseID), ProductID char(3) references Product(ProductID),
  Quantity int check (Quantity >= 0), primary key (WarehouseID, ProductID));

create or replace function kt_succhua() returns trigger as $$
declare v_max int; v_sum int;
begin
  -- khoa dong Warehouse: cac giao dich cung ghi vao mot kho phai xep hang tuan tu
  select MaxCapacity into v_max from Warehouse where WarehouseID = new.WarehouseID for update;
  -- READ COMMITTED: cau lenh tiep theo thay du lieu da commit cua giao dich truoc
  if tg_op = 'INSERT' then
    select coalesce(sum(Quantity), 0) into v_sum from Instock where WarehouseID = new.WarehouseID;
  else
    select coalesce(sum(Quantity), 0) into v_sum from Instock
     where WarehouseID = new.WarehouseID and not (WarehouseID = old.WarehouseID and ProductID = old.ProductID);
  end if;
  if v_max is not null and v_sum + new.Quantity > v_max then
    raise exception 'Vuot suc chua toi da cua kho';
  end if;
  return new;
end;
$$ language plpgsql;
create trigger trg_kt_succhua_ins before insert on Instock for each row execute function kt_succhua();
create trigger trg_kt_succhua_upd before update on Instock for each row execute function kt_succhua();

create or replace function kt_succhua_kho() returns trigger as $$
declare v_sum int;
begin
  if new.MaxCapacity is not null and (old.MaxCapacity is null or new.MaxCapacity < old.MaxCapacity) then
    select coalesce(sum(Quantity), 0) into v_sum from Instock where WarehouseID = new.WarehouseID;
    if v_sum > new.MaxCapacity then
      raise exception 'Suc chua moi nho hon tong ton hien co';
    end if;
  end if;
  return new;
end;
$$ language plpgsql;
create trigger trg_kt_succhua_kho before update on Warehouse for each row execute function kt_succhua_kho();

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
