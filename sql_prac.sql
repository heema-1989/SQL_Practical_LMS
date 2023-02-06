USE user_orders;
ALTER TABLE orders
ADD FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE SET NULL;

ALTER TABLE orders
ADD FOREIGN KEY(product_id) REFERENCES products(product_id) ON DELETE SET NULL;

ALTER TABLE order_details
ADD PRIMARY KEY(order_id, product_id);

-- ALTER TABLE  user ADD gender VARCHAR(1);
SELECT * FROM user;
ALTER TABLE user
ADD COLUMN contact_no VARCHAR(45) AFTER address;
/*Inserting items into user, orders and products table using INSERT INTO.*/

INSERT INTO user VALUES(1,'Heema', 'Goratela', 'heemag2002@gmail.com', 'abc', '282839', 'F');
INSERT INTO user VALUES(2,'Dhatri', 'Goratela', 'dhatrig2007@gmail.com', 'xyz', '17273', 'F');
INSERT INTO user VALUES(3,'Dhaval', 'Bheda', 'dhavalb@gmail.com', 'dff', '273744', 'M');
INSERT INTO user VALUES(4,'Megh', 'Patel', 'megh2009@gmail.com', 'gjhg', '182833', 'M');
INSERT INTO user VALUES(5,'Khushi', 'Rajpal', 'khushir@gmail.com', 'ahs', '1872873', 'F');
INSERT INTO user VALUES(6,'Preeti', 'Harjani', 'preeti405@gmail.com', 'fdf', '283834', 'F');
INSERT INTO user VALUES(7,'Kunal', 'Patel', 'kunalp@gmail.com', 'abf', '6868967', 'M');
INSERT INTO user VALUES(8,'Hinal', 'Dor', 'hinal2005@gmail.com', 'fgg', '45677', 'F');

SELECT * From user;

INSERT INTO products VALUES(101, 'Apple Airpods Pro', 23900);
INSERT INTO products VALUES(102, 'Redmibook pro', 39900);
INSERT INTO products VALUES(103, 'Dell inspiron', 73899);
INSERT INTO products VALUES(104, 'One plus T4340', 13149);
INSERT INTO products VALUES(105, 'Philips hair staightener', 1399);
INSERT INTO products VALUES(106, 'Loreal Paris brow kit', 13149);
INSERT INTO products VALUES(107, 'Dyson Airwrap Multi-Styler', 45900);

SELECT * from products;

INSERT INTO orders VALUES(1,1,102, '2022-01-05', 'Shipped', '2022-01-07');
INSERT INTO orders VALUES(2,5,103, '2022-02-02', 'Delivered', NULL);
INSERT INTO orders VALUES(3,1,101, '2022-02-03', 'Not Shipped', '2022-02-11');
INSERT INTO orders VALUES(4,8,104, '2022-01-27', 'Cancelled', NULL);
INSERT INTO orders VALUES(5,3,103, '2022-01-25', 'Shipped', '2022-01-31');
INSERT INTO orders VALUES(6,4,102, '2022-01-16', 'Delivered', null);
INSERT INTO orders VALUES(7,3,102, '2022-01-10', 'Shipped', '2022-01-15');
INSERT INTO orders VALUES(8,4,101, '2022-02-02', 'Delivered', null);
INSERT INTO orders VALUES(9,5,105, '2022-01-30', 'Not shipped', '2022-02-05');
INSERT INTO orders VALUES(10,8,107, '2022-01-26', 'Shipped', '2022-01-31');
INSERT INTO orders VALUES(11,1,107, '2022-02-01', 'Delivered', null);
INSERT INTO orders VALUES(12,1,106, '2022-01-31', 'Shipped', '2022-02-04');
INSERT INTO orders VALUES(13,5,106, '2022-02-01', 'Not shipped', '2022-02-10');

-- DELETE FROM orders WHERE order_id BETWEEN 9 AND 13;

SELECT * FROM orders;

-- SELECT user.first_name, user.last_name, user.user_id, orders.order_id
-- FROM orders INNER JOIN user ON orders.user_id=user.user_id;

/*SELECT orders.order_id, products.product_id, products.product_name, user.first_name, user.last_name, user.user_id, orders.order_placed_date,
coalesce(datediff(orders.expected_delivery_date, orders.order_placed_date) ,0) AS expected_delivery_in_days
FROM orders INNER JOIN products ON orders.product_id=products.product_id
INNER JOIN user ON orders.user_id=user.user_id;*/

/*1. Fetch all the User order list that includes customer_name, product_names, order_date, expected_delivery(in days)*/

SELECT user.first_name, user.last_name,products.product_name, orders.order_placed_date, orders.order_status,
coalesce(datediff(orders.expected_delivery_date, orders.order_placed_date) ,0) AS expected_delivery_in_days
FROM orders INNER JOIN products ON orders.product_id=products.product_id
INNER JOIN user ON orders.user_id=user.user_id ORDER BY expected_delivery_in_days DESC;

/*2. . Create summary report which provide information about*/

/*All undelivered Orders*/
SELECT o.order_id, u.first_name, u.last_name, p.product_name,o.order_placed_date, o.order_status FROM 
orders AS o INNER JOIN products AS p ON o.product_id=p.product_id
INNER JOIN user AS u ON o.user_id=u.user_id
WHERE o.order_status!='Delivered' AND o.order_status!='Cancelled' ORDER BY order_placed_date;

/*5 Most recent orders*/
SELECT o.order_id, u.first_name, u.last_name, p.product_name,o.order_placed_date FROM
orders AS o INNER JOIN products AS p ON o.product_id=p.product_id
INNER JOIN user AS u ON o.user_id=u.user_id
ORDER BY order_placed_date DESC LIMIT 5;

/*Top 5 active users (Users having most number of orders)*/
SELECT  u.user_id,u.first_name, u.last_name,COUNT(o.user_id) AS order_count_of_users FROM
orders AS o INNER JOIN user AS u ON o.user_id=u.user_id GROUP BY o.user_id ORDER BY order_count_of_users DESC LIMIT 5; 

/*Inactive users (Users who hasn’t done any order)*/
SELECT u.user_id, u.first_name, u.last_name,IF(COUNT(o.user_id)=0,"inactive_user","active_user") AS user_status FROM
orders AS o RIGHT JOIN user AS u ON o.user_id=u.user_id  GROUP BY u.user_id;

SELECT u.user_id, u.first_name, u.last_name,IF(COUNT(o.user_id)=0,"inactive_user","active_user") AS user_status FROM
orders AS o RIGHT JOIN user AS u ON o.user_id=u.user_id  GROUP BY u.user_id HAVING COUNT(o.user_id)=0;

/*Top 5 Most purchased products*/
SELECT p.product_id, p.product_name, COUNT(o.product_id) AS product_count FROM
orders AS o INNER JOIN products AS p ON o.product_id=p.product_id GROUP BY o.product_id ORDER BY product_count DESC LIMIT 5;

/*Most expensive and most cheapest orders*/
/*Most expensive order*/ 
WITH RESULT AS
(
	SELECT  o.order_id,p.product_id, p.product_name, p.price, dense_rank() over (ORDER BY p.price DESC) AS most_expensive_order
	FROM products AS p INNER JOIN orders AS o ON p.product_id=o.product_id
)
SELECT * FROM RESULT WHERE RESULT.most_expensive_order=1;
/*Most cheapest orders*/
WITH RESULT AS
(
	SELECT  o.order_id,p.product_id, p.product_name, p.price, dense_rank() over (ORDER BY p.price ASC) AS most_cheapest_order
	FROM products AS p INNER JOIN orders AS o ON p.product_id=o.product_id
)
SELECT * FROM RESULT WHERE RESULT.most_cheapest_order=1;
 

