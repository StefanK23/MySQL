CREATE DATABASE IF NOT EXISTS `hotel`; 
USE `hotel`;

CREATE TABLE departments (
	id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(50)
);

INSERT INTO departments(name) VALUES('Front Office'), ('Support'), ('Kitchen'), ('Other');

CREATE TABLE employees (
	id INT PRIMARY KEY AUTO_INCREMENT,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	job_title VARCHAR(50) NOT NULL,
	department_id INT NOT NULL,
	salary DOUBLE NOT NULL,
	CONSTRAINT `fk_department_id` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`)
);

INSERT INTO `employees` (`first_name`,`last_name`, `job_title`,`department_id`,`salary`) VALUES
	('John', 'Smith', 'Manager',1, 900.00),
	('John', 'Johnson', 'Customer Service',2, 880.00),
	('Smith', 'Johnson', 'Porter', 4, 1100.00),
	('Peter', 'Petrov', 'Front Desk Clerk', 1, 1100.00),
	('Peter', 'Ivanov', 'Sales', 2, 1500.23),
	('Ivan' ,'Petrov', 'Waiter', 3, 990.00),
	('Jack', 'Jackson', 'Executive Chef', 3, 1800.00),
	('Pedro', 'Petrov', 'Front Desk Supervisor', 1, 2100.00),
	('Nikolay', 'Ivanov', 'Housekeeping', 4, 1600.00);
	

	
CREATE TABLE rooms (
	id INT PRIMARY KEY AUTO_INCREMENT,
	`type` VARCHAR(30)
);

INSERT INTO rooms(`type`) VALUES('apartment'), ('single room');

CREATE TABLE clients (
	id INT PRIMARY KEY AUTO_INCREMENT,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	room_id INT NOT NULL,
    CONSTRAINT fk_clients_rooms
    FOREIGN KEY (room_id)
    REFERENCES rooms(id)
);

INSERT INTO clients(`first_name`,`last_name`,`room_id`) 
VALUES('Pesho','Petrov', 1),('Gosho','Georgiev', 2),
('Mariya','Marieva', 2), ('Katya','Katerinova', 1), ('Nikolay','Nikolaev', 2);


#Exercise 1 -----!------

SELECT `id`, `first_name`,`last_name`, `job_title`from employees ORDER BY id ;


#Exercise 2 -----!------
SELECT `id`, concat(`first_name`,' ',`last_name`) AS 'full name' ,
`job_title` as `Job title`,
`salary` as `Salary`
FROM employees WHERE salary > 1000 ORDER BY id; 

#Exercise -----!------

SELECT `last_name`, `department_id` from employees where `department_id` = 1;
SELECT `last_name`, `salary` from employees  where `salary` <= 1100; 

SELECT `id`, `last_name` from employees
 where NOT(`id` = 3  OR `id` = 4) ORDER BY id;
 
 SELECT `id`, concat_ws(' ', `first_name`, `last_name` ) AS `Full name`, `salary` FROM employees 
 WHERE `salary` BETWEEN 1000 and 2000; 
 
SELECT * FROM employees AS e 
WHERE e.department_id = 1 AND e.salary >= 1000;

#Exercise 3 -----!------
UPDATE employees SET `salary` = `salary` + 100 WHERE `job_title` = 'Manager';
SELECT `salary` from employees ;
 
 #Exercise -----!------
 
 CREATE VIEW `v_hr_result_set` AS SELECT concat(`first_name`,' ',`last_name`) as 'Full name',`salary`
 FROM employees ORDER BY `department_id`;
 SELECT * FROM `v_hr_result_set`;
 
 CREATE VIEW `v_hr_result_set1` AS SELECT concat(`first_name`,' ',`last_name`) as 'Full name',`salary`,`department_id`
 FROM employees ORDER BY `department_id` ;
 
 
 #Exercise 4 -----!------
 
CREATE VIEW `v_top_paid_employee` AS SELECT * FROM employees ORDER BY `salary` DESC LIMIT 1;
SELECT * FROM `v_top_paid_employee` ;

 #Exercise 5 -----!------
 SELECT * from employees AS e WHERE e.department_id = 4 AND e.salary >= 1000 ; 
 
 #Exercise 6 ----!----- 
 
  DELETE FROM `employees` WHERE `department_id` = 1 OR `department_id` = 2 ;
  SELECT * FROM employees;
 
 
 
 