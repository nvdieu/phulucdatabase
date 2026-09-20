create database QLSinhVien;
use QLSinhVien;

create table Subject (
SubjectID varchar(5) primary key,
SubjectName varchar(50) not null,
Unit int check (Unit > 0)
);

create table Class (
ClassID varchar(5) primary key,
ClassName varchar(20) not null,
ClassYear int
);

create table Student (
StudentID varchar(5) primary key,
StudentName varchar(50) not null,
StudentAddress varchar(100),
ClassID varchar(5),
foreign key (ClassID) references Class(ClassID)
);

create table StudentGrade (
StudentID varchar(5),
SubjectID varchar(5),
Grade float check (Grade between 0 and 10),
primary key (StudentID, SubjectID),
foreign key (StudentID) references Student(StudentID),
foreign key (SubjectID) references Subject(SubjectID)
);

-- Du lieu mau
insert into Subject values
('S01','Co so du lieu',3), ('S02','Cau truc du lieu',3),
('S03','Lap trinh Java',4), ('S04','Mang may tinh',2);

insert into Class values
('C01','DB01',2025), ('C02','DB02',2025), ('C03','AI01',2026);

insert into Student values
('T01','Nguyen Van A','Q1, Tp.HCM','C01'),
('T02','Tran Thi B','Q2, Tp.HCM','C01'),
('T03','Le Van C','Q3, Tp.HCM','C02'),
('T04','Pham Thi D',null,'C03');
-- T04 chua co dia chi (NULL hop le vi khong bat buoc)

insert into StudentGrade values
('T01','S01',8.5), ('T01','S02',7.0), ('T01','S03',9.0), ('T01','S04',6.5),
('T02','S01',5.5), ('T02','S02',6.0),
('T03','S01',9.5), ('T03','S02',8.0), ('T03','S03',7.5), ('T03','S04',8.5);
-- T04 chua co diem mon nao (dung cho bai tap "sinh vien chua co diem")
