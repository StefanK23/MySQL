drop schema ruk_database;
Create SCHEMA ruk_database;

CREATE TABLE clients (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`full_name` VARCHAR(50) NOT NULL,
`age` INT NOT NULL
);

CREATE TABLE bank_accounts (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`account_number` VARCHAR(10) NOT NULL,
`balance` DECIMAL (10,2) NOT NULL,
`client_id` INT NOT NULL UNIQUE ,

CONSTRAINT fk_clients_bank_accounts
FOREIGN KEY (`client_id`)
REFERENCES `clients`(id)
);

CREATE TABLE cards (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`card_number` VARCHAR(19) NOT NULL,
`card_status` VARCHAR(7) NOT NULL, 
`bank_account_id` INT NOT NULL,

CONSTRAINT fk_cards_bank_accounts 
FOREIGN KEY (`bank_account_id`)
REFERENCES bank_accounts(id)
);

CREATE TABLE branches(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE employees (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR (20) NOT NULL,
`last_name` VARCHAR (20) NOT NULL,
`salary` DECIMAL(10,2) NOT NULL,
`started_on` DATE NOT NULL ,
`branch_id` INT NOT NULL ,

CONSTRAINT fk_employees_branches
FOREIGN KEY (`branch_id`)
REFERENCES branches(id)
);

CREATE TABLE employees_clients (
`employee_id` INT,
`client_id` INT ,

CONSTRAINT fk_employees_employees_clients
FOREIGN KEY (`employee_id`)
REFERENCES employees(id),

CONSTRAINT fk_clients_employees_clients
FOREIGN KEY (`client_id`)
REFERENCES clients(id)
);

# PART II 
#Exercise --2-- INSERT 
 
 INSERT INTO cards (`card_number`,`card_status`, `bank_account_id`)
 SELECT reverse(`full_name`), 'Active', `id` from clients 
 WHERE `id` BETWEEN 191 AND 200;
 
 #Exercise --3-- UPDATE 
 UPDATE clients as c 
	JOIN employees_clients as ec  ON c.id = ec.employee_id 
    SET ec.employee_id = (SELECT * from (SELECT ec1.employee_id FROM employees_clients as ec1
		GROUP BY ec1.employee_id
        ORDER BY count(ec1.employee_id) asc, ec1.employee_id LIMIT 1) as ss)
        WHERE ec.client_id = ec.employee_id;
 
#Exercise --4-- DELETE 

DELETE employees from employees  
LEFT JOIN employees_clients  ON employees .id = employees_clients.employee_id 
 WHERE employees_clients.employee_id IS NULL ;
 
 
 #Exercise --5-- 
 SELECT  c.`id`,c.`full_name` from clients as c
 ORDER BY c.`id`;
 
 #Exercise --6-- 
 SELECT e.`id`, concat_ws(' ', e.`first_name`,e.`last_name`) as `full_name` , concat('$',`salary`) as `salary` ,`started_on` 
 FROM employees as e 
 WHERE `salary` >= 100000 AND `started_on` >= '2018-01-01' 
 ORDER BY `salary` desc , e.id;
 
 #Exercise --7-- 
 SELECT car.`id`, concat_ws(' ', car.`card_number`,':',cl.`full_name`) as `card_token` from clients as cl 
 JOIN `bank_accounts` as ba ON cl.id = ba.client_id 
 JOIN `cards` as car ON ba.id = car.bank_account_id 
 
 ORDER BY car.`id` desc;


#Exercise --8-- 
SELECT concat_ws(' ',e.`first_name`, e.`last_name`) as `name` , `started_on`, count(ec.`employee_id`) as `count_of_clients` 
	FROM employees as e
    JOIN employees_clients as ec ON e.id  = ec.employee_id
   GROUP BY ec.`employee_id`
    ORDER BY `count_of_clients` desc, ec.employee_id asc LIMIT 5;
    
    #Exerise --9-- 
    SELECT 
    br.name, COUNT(cc.id) count_of_cards
FROM
    branches br
        LEFT JOIN
    employees e ON e.branch_id = br.id
        LEFT JOIN
    employees_clients ec ON e.id = ec.employee_id
        LEFT JOIN
    clients c ON c.id = ec.client_id
        LEFT JOIN
    bank_accounts ba ON c.id = ba.client_id
        LEFT JOIN
    cards cc ON cc.bank_account_id = ba.id
GROUP BY br.name
ORDER BY count_of_cards DESC , br.name;

#Exercise --10-- 

DELIMITER //

CREATE FUNCTION udf_client_cards_count(client_name VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE cards_count INT;
    
    SET cards_count := (
		SELECT COUNT(*)
        FROM clients c
        INNER JOIN bank_accounts ba
        ON c.id = ba.client_id
        INNER JOIN cards cc
        ON ba.id = cc.bank_account_id
        WHERE c.full_name = client_name
        GROUP BY c.id);
        
	IF cards_count IS NULL
    THEN SET cards_count := 0;
    END IF;
    
    RETURN cards_count;
END //

DELIMITER ;

SELECT full_name, 
	udf_client_cards_count(full_name) cards
FROM clients

#Exercise --11-- 
DELIMITER //
CREATE PROCEDURE udp_clientinfo(client_name VARCHAR(30))
BEGIN
	SELECT c.full_name,
		c.age,
        ba.account_number,
        CONCAT('$', ba.balance) balance
	FROM clients c
    INNER JOIN bank_accounts ba
    ON ba.client_id = c.id
    WHERE c.full_name = client_name;
END //

DELIMITER ;

CALL udp_clientinfo('Hunter Wesgate');