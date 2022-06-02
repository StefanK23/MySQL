CREATE DATABASE IF NOT EXISTS restaurant;
use restaurant;

CREATE TABLE departments (
	id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
	id INT PRIMARY KEY AUTO_INCREMENT,
	first_name VARCHAR(30) NOT NULL,
	last_name VARCHAR(30) NOT NULL,
	department_id INT NOT NULL,
	salary DOUBLE NOT NULL,
	CONSTRAINT fk_department_id FOREIGN KEY(`department_id`) REFERENCES departments(`id`)
);

CREATE TABLE categories (
	id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(30) NOT NULL
);

CREATE TABLE  products (
	id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(50) NOT NULL,
	category_id INT NOT NULL,
	price DOUBLE NOT NULL,
	CONSTRAINT fk_cateogory_id FOREIGN KEY(`category_id`) REFERENCES categories(`id`)
);

INSERT INTO departments(name) VALUES ("Management"), ("Kitchen Staff"), ("Wait Staff");

INSERT INTO employees (first_name, last_name, department_id, salary) VALUES ("Jasmine","Maggot",2,1250.00), 
("Nancy","Olson",2,1350.00), ("Karen","Bender",1,2400.00), ("Pricilia","Parker",2,980.00),
("Stephen","Bedford",2,780.00),("Jack","McGee",1,1700.00),("Clarence","Willis",3,650.00),
("Michael","Boren",3,780.00),("Michael","Boren",3,780.00);

INSERT INTO categories(name) VALUES("salads"),("appetizers"),("soups"),("main"),("desserts");

INSERT INTO products (name, category_id,price) VALUES ("Lasagne", 4,12.99),
("Linguine Positano with Chicken", 4,11.69),
("Chicken Marsala", 4,13.69),
("Calamari", 2,14.89),
("Tomato Caprese with Fresh Burrata", 2,7.99),
("Wood-Fired Italian Wings", 2,9.90),
("Caesar Side Salad", 1,8.79),
("House Side Salad", 1,6.79),
("Johny Rocco Salad", 1,6.90),
("Minestrone", 3,8.89),
("Sausage & Lentil", 3,7.90),
("Mama Mandola’s Sicilian Chicken Soup", 3,6.90),
("Tiramisú", 5,4.90),
("John Cole", 5,5.60),
("Mini Cannoli", 5,5.60);
#Exercise ---!---

SELECT department_id, sum(`salary`) as 'Total Salary' from employees 
GROUP BY department_id ORDER BY department_id;  
 
#Exercise --1-- 
SELECT `department_id`, COUNT(`department_id`) AS `Number of employees`
FROM `employees`
GROUP BY `department_id`
ORDER BY `department_id`, `Number of employees`;


#Exercise --2-- 
SELECT `department_id`, round(AVG(`salary`), 2) as 'Average Salary' from `employees`
GROUP BY `department_id` ORDER BY department_id;

#Exercise --3-- 
SELECT `department_id` , round(min(`salary`),2) as `Min Salary` from employees 
 GROUP BY department_id HAVING `Min Salary` > 800 ;  

#Exercise --!-- 
SELECT `department_id`, MAX(`salary`) as 'Max Salary' from employees 
GROUP BY department_id;

SELECT `department_id`, MIN(`salary`) as 'Min Salary' from employees 
GROUP BY department_id;

SELECT `department_id`, round(AVG(`salary`),2) as 'AVG Salary' from employees 
GROUP BY department_id;

SELECT `department_id`, SUM(`salary`) as 'TotalSalary' from employees 
GROUP BY department_id HAVING `TotalSalary` < 4100;

#Exercise --4-- 
SELECT count(`category_id`) as 'Appetizers' from products WHERE price > 8 
GROUP BY category_id HAVING category_id =2;

#Exercise --5--

SELECT `category_id`, round(AVG(`price`),2) as 'Average Price', 
round(MIN(`price`),2) as 'Cheapest Product' , round(MAX(`price`),2) as 'Most Expensive Product' from products 
GROUP BY category_id;


