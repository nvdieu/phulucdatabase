create database QLSinhVien;
use QLSinhVien;

create table Subject (
SubjectID char(3) primary key,
SubjectName varchar(30) not null,
Unit int check (Unit > 0)
);

create table Class (
ClassID char(3) primary key,
ClassName varchar(30) not null,
ClassYear varchar(30)
);

create table Student (
StudentID char(3) primary key,
StudentName varchar(30) not null,
StudentAddress varchar(30),
ClassID char(3),
foreign key (ClassID) references Class(ClassID)
);

create table StudentGrade (
StudentID char(3),
SubjectID char(3),
Grade float check (Grade between 0 and 10),
primary key (StudentID, SubjectID),
foreign key (StudentID) references Student(StudentID),
foreign key (SubjectID) references Subject(SubjectID)
);

-- Du lieu mau (dong T01-T11 lay tu vi du INSERT o Chuong 3; T12, T13 bo sung)
insert into Subject values
('S01','Database System',3), ('S02','Database Design',3),
('S03','Discrete Mathematics',3), ('S04','Artificial Intelligence',4),
('S05','System Analysis And Design',3);

insert into Class values
('C01','AI-2023','2023'), ('C02','AI-2024','2024'), ('C03','Data science-2025','2025');

insert into Student values
('T01','Nguyễn Văn A','Ho Chi Minh','C01'),
('T02','Nguyễn Văn B','Ho Chi Minh','C01'),
('T03','Nguyễn Văn C','Đồng Nai','C01'),
('T04','Lê Thị A','Ho Chi Minh','C02'),
('T05','Lê Thị B','Ho Chi Minh','C02'),
('T06','Lê Thị B','Đồng Nai','C02'),
('T07','Trần Văn A','Long An','C02'),
('T08','Trần Văn A','Ho Chi Minh','C03'),
('T09','Trần Văn B','Long An','C03'),
('T10','Đặng Văn A','Đồng Nai','C03'),
('T11','Đặng Văn A','Long An','C03'),
-- bo sung: T12 chua co dia chi (NULL), da co diem tat ca 5 mon; T13 co diem 4 mon (tru S04)
('T12','Phạm Thị D',null,'C01'),
('T13','Vũ Văn E','Long An','C03');

insert into StudentGrade values
('T01','S01',4), ('T01','S02',8), ('T01','S03',6),
('T02','S01',3), ('T02','S04',5),
('T03','S01',6), ('T03','S04',7), ('T03','S05',9),
('T04','S02',2), ('T04','S04',8), ('T04','S05',3),
-- bo sung
('T12','S01',8.5), ('T12','S02',7), ('T12','S03',9), ('T12','S04',6.5), ('T12','S05',8),
('T13','S01',9), ('T13','S02',8), ('T13','S03',7), ('T13','S05',6);
-- T05-T11 chua co diem mon nao (dung cho bai tap "sinh vien chua co diem")
