create database s3b2;
use s3b2;
create table if not exists customers(
cid int primary key auto_increment,
cName varchar(255),
cAge int
);
create table if not exists orders(
old int primary key auto_increment,
cid int, 
constraint lk_01 foreign key(cid) references customers(cid)
);
alter table orders
add column oDate datetime,
add column oTotalPrice double;
create table if not exists products(
pid int primary key auto_increment,
pName varchar(255),
pPrice double
);
create table if not exists orderDetail(
old int,
constraint lk_02 foreign key(old) references orders(old),
pid int,
constraint lk_03 foreign key(pid) references products(pid),
odQuantity int
);
insert into customers(cName,cAge) values('Minh Quan',10),('NgocOaNH',20),('Hong Ha',50);
INSERT INTO orders (cid, oDate, oTotalPrice) 
VALUES 
(1, STR_TO_DATE('3/21/2006', '%m/%d/%Y'), 150000),
(2, STR_TO_DATE('3/23/2006', '%m/%d/%Y'), 200000),
(1, STR_TO_DATE('3/16/2006', '%m/%d/%Y'), 170000);
insert into products(pName,pPrice)value('MayGiat',300),('Tulanh',500),('Dieuhoa',700),('Quat',100),
('Bep dien',200),('May hut khi',500);
insert into orderDetail(old,pid,odQuantity)values(1,1,3),(1,4,7),(1,4,2),(2,1,1),(3,1,8),(2,5,4),(2,3,4);
select old,oDate,oTotalPrice from Orders;
select c.*,p.pName,p.pPrice,od.odQuantity from customers as c inner join orders as o on c.cid=o.cid inner join orderDetail as od on o.old=od.old
inner join products as p on od.pid=p.pid where c.cid=o.cid;
select* from customers;
select c.* from customers as c left join orders as o on c.cid=o.cid where o.cid is null;
SELECT o.old, o.oDate, SUM(od.odQuantity * p.pPrice) AS totalPrice  
FROM orders AS o 
INNER JOIN orderDetail AS od ON o.old = od.old 
INNER JOIN products AS p ON od.pid = p.pid 
GROUP BY o.old, o.oDate;


-- Hiển thị tất cả customer có đơn hàng trên 150000
create view Above15k as
select c.*,o.oTotalPrice from customers as c inner join orders as o on o.old =c.cid where o.oTotalPrice> 150000;

select *from Above15k ;
-- Hiển thị sản phẩm chưa được bán cho bất cứ ai
select p.* from products as p left join orderdetail as od on od.pid=p.pid where od.pid is null ;
-- left join ko có trả về null

select o.old,o.oDate,sum(p.pPrice*od.odQuantity) as totalPrice from orders as o 
join orderdetail as od on od.old=o.old
join products as p on p.pid=od.pid
group by  o.old,o.oDate
order by totalPrice desc
limit 1;


select o.old,o.odate,sum(p.pPrice*od.odQuantity) as TotalPrice from orders as o join
orderdetail as od on od.old=o.old
join products as p on p.pid=od.pid
group by  o.old,o.odate
order by TotalPrice desc
limit 1;

-- Hiển thị sản phẩm có giá tiền lớn nhất

select * from products order by pPrice desc limit 1;

select o.* from orders as o join orderdetail as od on o.old=od.old
group by (o.old)
having count(od.pid)>2;

-- Hiển thị người dùng nào mua nhiều sản phẩm “Bep Dien” nhất

select c.*,Sum(od.odQuantity) as Most from customers as c 
inner join orders as o on o.cid=c.cid
inner join orderdetail as od on od.old=o.old
inner join products as p on p.pid=od.pid where p.pName like 'Bep dien'
group by c.cid
ORDER BY Most DESC
limit 1;
-- Tạo view hiển thị tất cả customer
create view View_customer as select * from customers; 
select* from View_customer;
-- Tạo view hiển thị tất cả order có oTotalPrice trên 150000
create view Above15k as
select c.*,o.oTotalPrice from customers as c inner join orders as o on o.old =c.cid where o.oTotalPrice> 150000;
select *from Above15k; 
-- Đánh index cho bảng customer ở cột cName
create index index_product on products (pName);
-- Đánh index cho bảng customer ở cột cName
create index index_customers on customers(cName);

DELIMITER //

create procedure TotalPriceMin()
begin 
select o.old,o.oDate, sum(p.pPrice*od.odQuantity)as TotalPrice from orders as o
 join orderdetail as od on od.old=o.old join products as p on p.pid=od.pid
 group by o.old,o.oDate
 order by TotalPrice asc
 limit 1;
end//
DELIMITER ;
drop procedure TotalPriceMin;
call TotalPriceMin();

-- Tạo store procedure hiển thị người dùng nào mua sản phẩm “May Giat” ít nhất
DELIMITER //
create procedure littleMayGiat()
begin
select c.*,sum(od.odquantity) as quantity from customers as c join orders as o on o.cid=c.cid
join orderdetail as od on od.old=o.old
join products as p on p.pid=od.pid where p.pname like 'Bep dien' 
group by c.cid
order by quantity asc
limit 1;
end//
DELIMITER ;
call littleMayGiat();