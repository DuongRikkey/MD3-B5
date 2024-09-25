create database s3b5;
use s3b5;
CREATE TABLE account (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100),
    password VARCHAR(255),
    address VARCHAR(255),
    status BIT
);
CREATE TABLE product (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    created DATE,
    price DOUBLE,
    stock INT,
    status BIT
);
CREATE TABLE bill (
    id INT PRIMARY KEY AUTO_INCREMENT,
    bill_type BIT,  -- 0: Nhập, 1: Xuất
    acc_id INT,
    created DATETIME,
    auth_date DATETIME,
    FOREIGN KEY (acc_id) REFERENCES account(id)
);
CREATE TABLE bill_detail (
    id INT PRIMARY KEY AUTO_INCREMENT,
    bill_id INT,
    product_id INT,
    quantity INT,
    price DOUBLE,
    FOREIGN KEY (bill_id) REFERENCES bill(id),
    FOREIGN KEY (product_id) REFERENCES product(id)
);

INSERT INTO account (id, username, password, address, status)
VALUES 
(1, 'Hùng', '123456', 'Nghệ An', TRUE),
(2, 'Cường', '654321', 'Hà Nội', TRUE),
(3, 'Bách', '135790', 'Hà Nội', TRUE);
INSERT INTO bill (id, bill_type, acc_id, created, auth_date)
VALUES
(1, 0, 1, '2022-02-11', '2022-03-12'),
(2, 0, 1, '2023-10-05', '2023-10-10'),
(3, 1, 2, '2024-05-15', '2024-05-20');

INSERT INTO product (id, name, created, price, stock, status)
VALUES
(1, 'Quần dài', '2022-03-12', 1200, 5, True),
(2, 'Áo dài', '2023-03-15', 1500, 8, True),
(3, 'Mũ cối', '1999-03-08', 1600, 10, True);
INSERT INTO bill_detail (id, bill_id, product_id, quantity, price)
VALUES
(1, 1, 1, 3, 1200),
(2, 1, 2, 4, 1500),
(3, 2, 1, 1, 1200),
(4, 3, 2, 4, 1500),
(5, 4, 3, 7, 1600);


select a.* from account as a
order by a.username desc;

select bd.* from bill_detail as bd
order by bd.bill_id;

select b.* from bill as b
where b.created between '2022-02-11' and '2023-05-15';

select p.* from product as p
where p.status=1;

-- Tạo store procedure hiển thị tất cả thông tin account mà đã tạo ra 5 đơn hàng trở lên

DELIMITER //
create procedure ShowAccountsWithFiveBillsOrMore()
begin
select a.* from account as a 
join bill as b on b.acc_id=a.id
group by a.id
having count(b.id) >=2 ;
end //
DELIMITER ;
  call ShowAccountsWithFiveBillsOrMore();
  
-- 2. Hiển thị tất cả sản phẩm chưa được bán  
DELIMITER //
create procedure nobuy()
begin
select p.* from product as  p left join bill_detail 
as bd on bd.product_id=p.id where bd.product_id is null;
end //
DELIMITER ;

call nobuy();
drop procedure nobuy;
-- Tạo store procedure hiển thị top 2 sản phẩm được bán nhiều nhất
DELIMITER //
create procedure top2()
begin
select p.*, sum(bd.quantity)as totalQuantity from product as p join bill_detail as bd on bd.product_id=p.id
group by p.id,p.name
order by totalQuantity desc
limit 2;
end //
DELIMITER ;
call top2();

-- Tạo store procedure thêm tài khoản
DELIMITER //
create procedure insert_account(username_new  VARCHAR(100) ,password_new  VARCHAR(255),address_new VARCHAR(255),status_new bit)
begin 
insert into account(username,password,address,status) values(username_new,password_new,address_new,status_new);
end //
DELIMITER ;

call insert_account('Duong','hihiiii','11',0)

DELIMITER //
create procedure touchbilld(bill_id int)
begin
select bd.* from bill_detail as bd 
 where bd.bill_id=bill_id;
 end //
 DELIMITER ;
 
call touchbilld(3);

-- Tạo ra store procedure thêm mới bill và trả về bill_id vừa mới tạo

DELIMITER //
create procedure insert_bill(
   IN bill_type_new BIT,  
   IN   acc_id_new INT,
   IN  created_new DATETIME,
   IN auth_date_new DATETIME,
   OUT new_bill_id INT )
begin
  insert into bill(bill_type,acc_id,created,auth_date) 
  values(bill_type_new,acc_id_new,created_new,auth_date_new);
  SET new_bill_id = LAST_INSERT_ID();
  end //
   
  DELIMITER ;
CALL insert_bill(1, 1, '2024-09-19 10:00:00', '2024-09-20 15:00:00', @new_bill_id);

-- Xem ID của bill mới tạo
SELECT  @new_bill_id 
DELIMITER //
 create procedure ProductAbove5()
 begin
 select p.id,p.name, Sum(bd.quantity) as totalquantity from product as p 
 join bill_detail as bd on bd.product_id=p.id
 group by  p.id,p.name
 having totalquantity >=5
 limit 5;
 end //
 DELIMITER ;
call ProductAbove5();

