create database QLKhoHang;
use QLKhoHang;

create table Category (
CategoryID char(3) primary key,
CategoryName varchar(30) not null
);

create table Product (
ProductID char(3) primary key,
ProductName varchar(30) not null,
UnitPrice float check (UnitPrice > 0),
CategoryID char(3),
foreign key (CategoryID) references Category(CategoryID)
);

create table Warehouse (
WarehouseID char(3) primary key,
WarehouseAddress varchar(30),
CategoryID char(3),
foreign key (CategoryID) references Category(CategoryID)
);

create table Instock (
WarehouseID char(3),
ProductID char(3),
Quantity int check (Quantity >= 0),
primary key (WarehouseID, ProductID),
foreign key (WarehouseID) references Warehouse(WarehouseID),
foreign key (ProductID) references Product(ProductID)
);

-- Du lieu mau
insert into Category values
('C01','Nong san'), ('C02','Dien tu'), ('C03','Van phong pham');

insert into Product values
('P01','Gao ST25',25000,'C01'), ('P02','Ca phe',80000,'C01'),
('P03','Tai nghe',150000,'C02'), ('P04','Chuot may tinh',120000,'C02'),
('P05','But bi',5000,'C03');
-- P05 chua duoc luu o kho nao (dung cho bai tap "san pham chua o kho")

insert into Warehouse values
('W01','123 Le Loi, Q1, Tp.HCM','C01'),
('W02','456 Nguyen Trai, Q5, Tp.HCM','C02'),
('W03','789 CMT8, Q10, Tp.HCM','C03');

insert into Instock values
('W01','P01',500), ('W01','P02',300),
('W02','P03',100), ('W02','P04',200),
('W03','P01',50);
-- W03 luu ca P01 (Nong san) du CategoryID cua W03 la C03 -- vi pham co y de bai tap Cau 18 Chuong 3 phat hien
