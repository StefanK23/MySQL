drop schema online_store;
CREATE SCHEMA online_store;


CREATE TABLE `brands` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `categories` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `reviews`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`content` TEXT ,
`rating` DECIMAL (10,2) NOT NULL,
`picture_url` VARCHAR(80) NOT NULL,
`published_at` DATETIME NOT NULL 
);

CREATE TABLE `products` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL,
`price` DECIMAL(19,2) NOT NULL,
`quantity_in_stock` INT ,
`description` TEXT,
`brand_id` INT NOT NULL,
`category_id` INT NOT NULL,
`review_id` INT ,

CONSTRAINT fk_products_brands
FOREIGN KEY (`brand_id`) 
REFERENCES `brands`(id),

CONSTRAINT fk_products_categories
FOREIGN KEY (`category_id`)
REFERENCES `categories`(id),

CONSTRAINT fk_products_reviews
FOREIGN KEY (`review_id`) 
REFERENCES `reviews`(id)
);

CREATE TABLE `customers` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(20) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`phone` VARCHAR(30) NOT NULL UNIQUE,
`address` VARCHAR(60) NOT NULL,
`discount_card` BIT NOT NULL DEFAULT FALSE
);


CREATE TABLE `orders`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`order_datetime` DATETIME NOT NULL,
`customer_id` INT NOT NULL,

CONSTRAINT fk_customers_orders
FOREIGN KEY (`customer_id`)
REFERENCES `customers`(id)
);



CREATE TABLE `orders_products`(
`order_id` INT ,
`product_id` INT ,

CONSTRAINT fk_orders_orders_products
FOREIGN KEY (`order_id`)REFERENCES `orders`(id) ,

CONSTRAINT fk_products_orders_products
FOREIGN KEY (`product_id`) REFERENCES `products`(id)
);


# PART II 
# Exercise --2-- INSERT
 
  # INSERT INTO cards (`card_number`,`card_status`, `bank_account_id`)
 # SELECT reverse(`full_name`), 'Active', `id` from clients 
 #  WHERE `id` BETWEEN 191 AND 200;

INSERT INTO `reviews`(`content`,`picture_url`,`published_at`,`rating`)
(SELECT LEFT(`description`,15), reverse(`name`), CONVERT('2020-10-10',DATETIME), `price`/8  from products 
 WHERE products.`id` >= 5);  
 
 INSERT INTO `reviews`(content,picture_url,`published_at`,rating)
(SELECT LEFT(p.`description`,15),REVERSE(p.`name`),('2010-10-10'), p.`price` = p.`price` / 8.00 FROM products as p
WHERE  p.id>=5);

insert into reviews(content, picture_url, published_at, rating) 
 (select
     left(p.description, 15),
     reverse(p.name),'2010-10-10', p.price / 8
 from products as p
 where id >= 5
 );
 
SELECT * from reviews;
 

#Exercise --3-- UPDATE 
UPDATE `products` 
SET `quantity_in_stock` = `quantity_in_stock` - 5 
WHERE `quantity_in_stock` >= 60 AND `quantity_in_stock` <= 70 ;

#Exercise --4-- DELETE 

DELETE customers from customers 
LEFT JOIN `orders` ON customers(id) = orders(`customer_id`)
WHERE `customer_id` IS NULL ;

#Second way 
DELETE FROM customers 
WHERE id NOT IN (
SELECT customer_id FROM orders as o
LEFT JOIN orders_products as op ON o.id = op.order_id);

#Exercise --5-- 
SELECT c.`id` ,c.`name` from categories as c 
ORDER BY c.`name` desc;

#Exercise --6-- 
SELECT p.`id`, br.`id` ,p.`name`, p.`quantity_in_stock` from `products` as p 
JOIN brands as br ON p.brand_id = br.id 
WHERE p.`price` > 1000 AND p.`quantity_in_stock` < 30 
ORDER BY p.`quantity_in_stock` asc, p.`id`;

#Exercise --7-- 
SELECT r.`id`, r.`content` ,r.`rating`,r.`picture_url`,r.`published_at` 
 FROM reviews as r 
 WHERE r.`content` LIKE 'My%' AND char_length(r.`content`) > 61 
 ORDER BY rating desc;
 
#Exercise --8-- 
SELECT DISTINCT
    CONCAT(c.first_name,' ', c.last_name) AS full_name,
    c.address,
    o.order_datetime
FROM
    customers AS c
        JOIN
    orders AS o ON o.customer_id = c.id 
WHERE o.order_datetime < DATE('2019-01-01')
ORDER BY full_name DESC;

#Exercise --9-- 

SELECT count(c.`id`)as `items_count` ,c.`name`, sum(pr.`quantity_in_stock`) as `total_quantity` from `categories` as c 
  JOIN `products` as pr ON c.`id` = pr.`category_id` 
 GROUP BY c.`id`
ORDER BY `items_count`desc, `total_quantity` asc LIMIT 5 ;

#Exercise --10--
DELIMITER $$
CREATE FUNCTION udf_customer_products_count(name VARCHAR(20))
returns INT
deterministic
BEGIN
RETURN (SELECT count(*) as total_products FROM customers as c
JOIN orders as o on c.id=o.customer_id
JOIN orders_products as op on o.id=op.order_id
join products as p on p.id=op.product_id
WHERE c.first_name= name);
END $$ 
DELIMITER ;

SELECT c.first_name,c.last_name, udf_customer_products_count('Shirley') as `total_products` FROM customers c
WHERE c.first_name = 'Shirley';


#Exercise --11--
DELIMITER $$$
 
CREATE PROCEDURE udp_reduce_price (category_name VARCHAR(50))
BEGIN
UPDATE products AS p LEFT JOIN `categories` AS c ON `p`.category_id = `c`.id 
LEFT JOIN `reviews` AS r ON `p`.review_id = `r`.id SET `p`.price = ROUND(0.7 * `p`.price,2) 
WHERE `r`.rating < 4 AND `c`.name = category_name;
END $$$
DELIMITER ;

CALL udp_reduce_price('Phones and tablets');