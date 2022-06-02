
drop SCHEMA softuni_stores_system;
Create SCHEMA softuni_stores_system;

CREATE TABLE `towns`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL UNIQUE 
);

CREATE TABLE `addresses` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL UNIQUE ,
`town_id` INT NOT NULL ,

CONSTRAINT fk_towns_addresses
FOREIGN KEY (`town_id`)
REFERENCES `towns`(id)
);

CREATE TABLE `stores`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL UNIQUE ,
`rating` FLOAT NOT NULL,
`has_parking` BOOLEAN DEFAULT FALSE ,
`address_id` INT NOT NULL ,

CONSTRAINT fk_stores_addresses
FOREIGN KEY(`address_id`)
REFERENCES `addresses`(id)
);

CREATE TABLE `employees`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(15) NOT NULL,
`middle_name` CHAR(1) ,
`last_name` VARCHAR(20) NOT NULL,
`salary` DECIMAL (19,2) DEFAULT 0, 
`hire_date` DATE NOT NULL,
`manager_id` INT ,
`store_id` INT NOT NULL,

CONSTRAINT fk_employees_employees
FOREIGN KEY (`manager_id`)
REFERENCES employees(`id`),

CONSTRAINT fk_employees_addresses 
FOREIGN KEY (`store_id`)
REFERENCES `stores`(id)
);

CREATE TABLE `pictures`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`url` VARCHAR (100) NOT NULL,
`added_on` DATETIME NOT NULL 
);

CREATE TABLE `categories`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `products`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE,
`best_before` DATE ,
`price` DECIMAL (10,2) NOT NULL,
`description` TEXT, 
`category_id` INT NOT NULL,
`picture_id` INT NOT NULL ,

CONSTRAINT fk_products_pictures 
FOREIGN KEY (`picture_id`)
REFERENCES `pictures`(id),

CONSTRAINT fk_products_categories
FOREIGN KEY (`category_id`)
REFERENCES `categories`(id)
);

CREATE TABLE `products_stores`(
`product_id` INT NOT NULL,
`store_id` INT NOT NULL, 

CONSTRAINT pk_products_stores
PRIMARY KEY (`product_id`,`store_id`),

CONSTRAINT fk_products_products_stores
FOREIGN KEY (`product_id`)
REFERENCES `products`(id),

CONSTRAINT fk_stores_products_stores
FOREIGN KEY (`store_id`)
REFERENCES `stores`(id)
);

#PART II 
#Exercise --2-- INSERT 

INSERT INTO products_stores(`product_id`, `store_id`)
	(SELECT p.`id`, 1 FROM  products as p
     WHERE p.`id` NOT IN (SELECT `product_id` FROM products_stores as ps));
     
     #Exercise --3-- UPDATE 
     UPDATE employees 
SET 
    `manager_id` = 3,
    `salary` = `salary` - 500
WHERE
    YEAR(`hire_date`) > 2003
        AND `store_id` NOT IN (SELECT 
            `id`
        FROM
            stores
        WHERE
            `name` IN ('Cardguard' , 'Veribet'));
            
	#Exercise --4-- DELETE
    DELETE FROM employees 
WHERE
    `manager_id` IS NOT NULL
    AND `salary` >= 6000;
    
    #Exercise --5-- 
    SELECT 
    `first_name`,
    `middle_name`,
    `last_name`,
    `salary`,
    `hire_date`
FROM
    employees
ORDER BY `hire_date` DESC;
    
    #Exercise --6--
    SELECT 
    p.`name` AS `product_name`,
    p.`price`,
    p.`best_before`,
    CONCAT(LEFT(p.`description`, 10), '...') AS `short_description`,
    `url`
FROM
    products AS p
        JOIN
    pictures AS pic ON p.`picture_id` = pic.`id`
WHERE
    CHAR_LENGTH(p.`description`) > 100
        AND YEAR(pic.`added_on`) < 2019
        AND p.`price` > 20
ORDER BY p.`price` DESC;

    #Exercise --7--
    
 SELECT 
    s.`name`,
    COUNT(p.`id`) AS `product_count`,
    ROUND(AVG(p.`price`), 2) AS `avg`
FROM
    stores AS s
        LEFT JOIN
    products_stores AS ps ON s.`id` = ps.`store_id`
        LEFT JOIN
    products AS p ON ps.`product_id` = p.`id`
GROUP BY s.`name`
ORDER BY `product_count` DESC , `avg` DESC , s.`id`;

    #Exercise --8--
    SELECT 
    CONCAT_WS(' ', e.`first_name`, e.`last_name`) AS `Full_name`,
    s.`name` AS `Store_name`,
    a.`name` AS `address`,
    e.`salary`
FROM
    employees AS e
        JOIN
    stores AS s ON e.store_id = s.id
        JOIN
    addresses AS a ON s.address_id = a.id
WHERE
    e.`salary` < 4000
        AND a.`name` LIKE '%5%'
        AND CHAR_LENGTH(s.`name`) > 8
        AND RIGHT(e.`last_name`, 1) = 'n';
        
    #Exercise --9--
    SELECT 
    REVERSE(s.`name`) AS `reversed_name`,
    CONCAT(UPPER(t.`name`), '-', a.`name`) AS `full_address`,
    COUNT(e.`id`) AS `employee_count`
FROM
    stores AS s
        LEFT JOIN
    addresses AS a ON s.`address_id` = a.`id`
        LEFT JOIN
    towns AS t ON a.`town_id` = t.`id`
        LEFT JOIN
    employees AS e ON s.`id` = e.`store_id`
GROUP BY s.`id`
HAVING `employee_count` > 0
ORDER BY `full_address`;
    
    #Exercise --10--
    
    DELIMITER $$
    CREATE FUNCTION udf_top_paid_employee_by_store(store_name VARCHAR(50))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    RETURN (SELECT 
    CONCAT(e.`first_name`, ' ', e.`middle_name`, '. ', e.`last_name`,
            ' works in store for ', 2020 - YEAR(`hire_date`),
            ' years') AS `full_info`
        FROM
            employees AS e
                LEFT JOIN
            stores AS s ON e.`store_id` = s.`id`
        WHERE
            s.`name` = store_name
        ORDER BY e.`salary` DESC
        LIMIT 1);
END $$
    #Exercise --11-- 
    
DELIMITER $$

CREATE PROCEDURE udp_update_product_price (address_name VARCHAR (50))
BEGIN
DECLARE amount INT;
    IF address_name LIKE '0%' 
    THEN SET amount = 100;
    ELSE SET amount = 200; 
    END IF;

UPDATE products AS p 
SET 
    `price` = `price` + amount
WHERE
    p.`id` IN (SELECT 
            ps.`product_Id`
        FROM
            addresses AS a
                JOIN
            stores AS s ON a.`id` = s.`address_id`
                JOIN
            products_stores AS ps ON s.`id` = ps.`store_id`
        WHERE
            a.`name` = address_name);
END $$

CALL udp_update_product_price('1 Cody Pass');
SELECT name, price FROM products WHERE id = 17;
    