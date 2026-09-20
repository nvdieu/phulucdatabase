create database QLDonDatHang;
use QLDonDatHang;

create table Category (
CategoryID varchar(5) primary key,
CategoryName varchar(50) not null
);

create table Product (
ProductID varchar(5) primary key,
ProductName varchar(50) not null,
UnitPrice float check (UnitPrice > 0),
CategoryID varchar(5),
foreign key (CategoryID) references Category(CategoryID)
);

create table Customer (
CustomerID varchar(5) primary key,
CustomerName varchar(50) not null,
CustomerAddress varchar(100)
);

create table Orders (
OrdersID varchar(5) primary key,
OrdersDate date not null,
RequiredDate date,
CustomerID varchar(5),
foreign key (CustomerID) references Customer(CustomerID),
check (RequiredDate >= OrdersDate)
);

create table OrdersDetail (
OrdersID varchar(5),
ProductID varchar(5),
Quantity int check (Quantity > 0),
primary key (OrdersID, ProductID),
foreign key (OrdersID) references Orders(OrdersID),
foreign key (ProductID) references Product(ProductID)
);

create table Delivery (
DeliveryID varchar(5) primary key,
DeliveryDate date,
OrdersID varchar(5),
foreign key (OrdersID) references Orders(OrdersID)
);

create table DeliveryDetail (
DeliveryID varchar(5),
ProductID varchar(5),
Quantity int check (Quantity > 0),
primary key (DeliveryID, ProductID),
foreign key (DeliveryID) references Delivery(DeliveryID),
foreign key (ProductID) references Product(ProductID)
);

-- Du lieu mau
insert into Category values ('C01','Nong san'), ('C02','Dien tu');

insert into Product values
('P01','Gao ST25',25000,'C01'), ('P02','Ca phe',80000,'C01'),
('P03','Tai nghe',150000,'C02');

insert into Customer values
('M01','Cong ty TNHH ABC','12 Vo Van Tan, Q3, Tp.HCM'),
('M02','Nguyen Van A','45 Ly Tu Trong, Q1, Tp.HCM');
-- M02 se chua co don hang nao (dung cho bai tap "khach hang chua dat hang")

insert into Orders values
('D01','2026-08-01','2026-08-10','M01'),
('D02','2026-08-15','2026-08-20','M01');

insert into OrdersDetail values
('D01','P01',10), ('D01','P02',5),
('D02','P03',2);

insert into Delivery values
('G01','2026-08-08','D01');
-- D02 chua co dot giao nao (dung cho bai tap "don hang chua duoc giao")

insert into DeliveryDetail values
('G01','P01',10), ('G01','P02',3);
-- Giao thieu P02 (dat 5 nhung chi giao 3) -- dung cho bai tap "giao chua du"
