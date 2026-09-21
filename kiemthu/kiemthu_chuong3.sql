-- KIEM THU CAC TRUY VAN CHUONG 3 (MySQL 8.0 / MariaDB 10.x)
-- Cach chay: xem cuoi file. Moi truy van co nhan (cot q) de doi chieu voi ket qua mong doi.

-- ################ QLSinhVien ################
use T_SV;
-- Vi du 3.19: diem trung binh cua sinh vien ten 'Nguyen Van A' (ten khong trung)
select 'VD3.19' as q, avg(Grade) as GPA
from StudentGrade as A, Student as B
where A.StudentID = B.StudentID and StudentName = 'Nguyen Van A';
-- Vi du 3.19 (truong hop trung ten): chon them ma sinh vien va nhom theo ma sinh vien
select 'VD3.19-trung-ten' as q, B.StudentID, avg(Grade) as GPA
from StudentGrade as A, Student as B
where A.StudentID = B.StudentID and StudentName = 'Nguyen Van A'
group by B.StudentID
order by B.StudentID;
-- Cau 7: lop co GPA cao nhat (bo diem NULL; dong hang thi tra ve tat ca)
with LopGPA as (
  select S.ClassID, avg(G.Grade) as GPA
  from Student S join StudentGrade G on S.StudentID = G.StudentID
  where G.Grade is not null
  group by S.ClassID)
select 'C7' as q, ClassID, GPA from LopGPA A
where not exists (select 1 from LopGPA B where B.GPA > A.GPA)
order by ClassID;
-- Cau 9: sinh vien co diem o tat ca mon hoc
select 'C9' as q, S.StudentID from Student S
where not exists (select 1 from Subject M
                  where not exists (select 1 from StudentGrade G
                                    where G.StudentID = S.StudentID and G.SubjectID = M.SubjectID))
order by S.StudentID;
-- Cau 10: sinh vien co diem o tat ca mon co so tin chi = 3
select 'C10' as q, S.StudentID from Student S
where not exists (select 1 from Subject M
                  where M.Unit = 3
                    and not exists (select 1 from StudentGrade G
                                    where G.StudentID = S.StudentID and G.SubjectID = M.SubjectID))
order by S.StudentID;

-- ################ QLKhoHang ################
use T_KHO;
-- Vi du 3.55 (Cach 2 cu, SAI): dem tong so dong Instock so voi so mat hang duoc phep chua
select 'VD3.55-cu' as q, X.WarehouseID from Instock X
group by X.WarehouseID
having count(*) = (select count(*) from Product A, Warehouse B
                   where X.WarehouseID = B.WarehouseID and A.CategoryID = B.CategoryID)
order by X.WarehouseID;
-- Vi du 3.55 (Cach 1): not exists + not in
select 'VD3.55-c1' as q, distinct_X.WarehouseID from (select distinct WarehouseID from Instock) distinct_X
where not exists (select 1 from Product A, Warehouse B
                  where distinct_X.WarehouseID = B.WarehouseID and A.CategoryID = B.CategoryID
                    and A.ProductID not in (select ProductID from Instock where WarehouseID = distinct_X.WarehouseID))
order by 2;
-- Vi du 3.55 (Cach 2 moi): chi dem cac dong dung loai hang cua kho
select 'VD3.55-c2' as q, X.WarehouseID
from Instock X
join Warehouse W on W.WarehouseID = X.WarehouseID
join Product P on P.ProductID = X.ProductID and P.CategoryID = W.CategoryID
group by X.WarehouseID, W.CategoryID
having count(*) = (select count(*) from Product A where A.CategoryID = W.CategoryID)
order by X.WarehouseID;
-- Vi du 3.61: mat hang chua trong it nhat 2 kho (HAVING dat truoc dau cham phay)
select 'VD3.61' as q, B.ProductID, ProductName, count(*) as SoKho
from Instock A, Product B
where A.ProductID = B.ProductID
group by B.ProductID, ProductName
having count(*) >= 2
order by B.ProductID;
-- Cau 12: kho co dia chi chua tu 'Ho Chi Minh'
select 'C12' as q, WarehouseID from Warehouse where WarehouseAddress like '%Ho Chi Minh%' order by WarehouseID;
-- Cau 16: kho co tong so luong ton lon nhat
with TongKho as (select WarehouseID, sum(Quantity) as Tong from Instock group by WarehouseID)
select 'C16' as q, WarehouseID, Tong from TongKho A
where not exists (select 1 from TongKho B where B.Tong > A.Tong)
order by WarehouseID;
-- Cau 18: kho luu tru mat hang thuoc nhieu hon mot loai hang
select 'C18' as q, WarehouseID from Instock I, Product P
where I.ProductID = P.ProductID
group by WarehouseID
having count(distinct CategoryID) > 1
order by WarehouseID;
-- Cau 19: kho luu tru day du moi mat hang thuoc loai 'C01'
select 'C19' as q, W.WarehouseID from Warehouse W
where not exists (select 1 from Product P
                  where P.CategoryID = 'C01'
                    and not exists (select 1 from Instock I
                                    where I.WarehouseID = W.WarehouseID and I.ProductID = P.ProductID))
order by W.WarehouseID;
-- Cau 20: kho luu tru day du moi mat hang ma kho duoc phep chua
select 'C20' as q, W.WarehouseID from Warehouse W
where exists (select 1 from Instock I0 where I0.WarehouseID = W.WarehouseID)
  and not exists (select 1 from Product P
                  where P.CategoryID = W.CategoryID
                    and not exists (select 1 from Instock I
                                    where I.WarehouseID = W.WarehouseID and I.ProductID = P.ProductID))
order by W.WarehouseID;

-- ################ QLDonDatHang ################
use T_DH;
-- Cau 22: khach hang co tong tri gia dat hang lon nhat
with TongKH as (
  select O.CustomerID, sum(OD.Quantity * P.UnitPrice) as TongTriGia
  from Orders O join OrdersDetail OD on O.OrdersID = OD.OrdersID
                join Product P on OD.ProductID = P.ProductID
  group by O.CustomerID)
select 'C22' as q, CustomerID, TongTriGia from TongKH A
where not exists (select 1 from TongKH B where B.TongTriGia > A.TongTriGia)
order by CustomerID;
-- Cau 24: don hang giao chua du (co mat hang da duoc giao nhung so luong giao tong cong < so luong dat)
select distinct 'C24' as q, OD.OrdersID
from OrdersDetail OD
join (select D.OrdersID, DD.ProductID, sum(DD.Quantity) as DaGiao
      from Delivery D join DeliveryDetail DD on D.DeliveryID = DD.DeliveryID
      group by D.OrdersID, DD.ProductID) G
  on G.OrdersID = OD.OrdersID and G.ProductID = OD.ProductID
where G.DaGiao < OD.Quantity
order by OD.OrdersID;
-- Cau 25: don hang dat day du moi mat hang thuoc danh muc 'C01'
select 'C25' as q, O.OrdersID from Orders O
where not exists (select 1 from Product P
                  where P.CategoryID = 'C01'
                    and not exists (select 1 from OrdersDetail OD
                                    where OD.OrdersID = O.OrdersID and OD.ProductID = P.ProductID))
order by O.OrdersID;
-- Cau 26: dot giao hang giao day du (so luong >= so luong dat) moi mat hang cua don hang tuong ung
select 'C26' as q, D.OrdersID, D.DeliveryID from Delivery D
where not exists (select 1 from OrdersDetail OD
                  where OD.OrdersID = D.OrdersID
                    and not exists (select 1 from DeliveryDetail DD
                                    where DD.DeliveryID = D.DeliveryID
                                      and DD.ProductID = OD.ProductID
                                      and DD.Quantity >= OD.Quantity))
order by D.OrdersID, D.DeliveryID;
