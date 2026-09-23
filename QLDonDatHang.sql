create database QLDonDatHang;
use QLDonDatHang;

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

create table Customer (
CustomerID char(3) primary key,
CustomerName varchar(30) not null,
CustomerAddress varchar(30)
);

create table Orders (
OrdersID char(3) primary key,
OrdersDate date not null,
RequiredDate date,
CustomerID char(3),
foreign key (CustomerID) references Customer(CustomerID),
check (RequiredDate >= OrdersDate)
);

create table OrdersDetail (
OrdersID char(3),
ProductID char(3),
Quantity int check (Quantity > 0),
primary key (OrdersID, ProductID),
foreign key (OrdersID) references Orders(OrdersID),
foreign key (ProductID) references Product(ProductID)
);

create table Delivery (
DeliveryID char(3) primary key,
DeliveryDate date,
OrdersID char(3),
foreign key (OrdersID) references Orders(OrdersID)
);

create table DeliveryDetail (
DeliveryID char(3),
ProductID char(3),
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
('M01','Cong ty TNHH ABC','12 Vo Van Tan, Q3, Ho Chi Minh'),
('M02','Nguyen Van A','45 Ly Tu Trong, Ho Chi Minh');
-- M02 se chua co don hang nao (dung cho bai tap "khach hang chua dat hang")

insert into Orders values
('R01','2026-08-01','2026-08-10','M01'),
('R02','2026-08-15','2026-08-20','M01');

insert into OrdersDetail values
('R01','P01',10), ('R01','P02',5),
('R02','P03',2);

insert into Delivery values
('D01','2026-08-08','R01');
-- R02 chua co dot giao nao (dung cho bai tap "don hang chua duoc giao")

insert into DeliveryDetail values
('D01','P01',10), ('D01','P02',3);
-- Giao thieu P02 (dat 5 nhung chi giao 3) -- dung cho bai tap "giao chua du"
