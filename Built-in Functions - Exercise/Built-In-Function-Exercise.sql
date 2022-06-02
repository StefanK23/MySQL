#Exercise --1--
SELECT `first_name`, `last_name` from employees where first_name LIKE 'Sa%' ORDER BY employee_id;
# Друго решение : 
# SELECT `first_name`, `last_name`
# FROM `employees`
-- WHERE `first_name` LIKE 'sa%'
-- WHERE LEFT(`first_name`, 2) = 'sa'
# WHERE SUBSTRING(`first_name`, 1, 2) = 'sa'
# ORDER BY `employee_id`;

#Exercise --2-- 
SELECT first_name , last_name from employees where last_name LIKE '%ei%' ORDER BY employee_id;

#Exercise --3--
SELECT first_name from employees where department_id IN (3,10) AND YEAR(`hire_date`) BETWEEN 1995 and 2005 ORDER BY employee_id;

#Exercise --4-- 
SELECT `first_name` ,`last_name` from employees where job_title NOT LIKE '%engineer%' ORDER BY employee_id;  

#Exercise --5-- 
SELECT `name` from towns where char_length(`name`) IN(5,6) ORDER BY `name`;

#Exercise --6-- 
SELECT town_id , `name` from towns WHERE LEFT(`name`, 1) IN('M','K','B','E') ORDER BY `name`;

#Exercise --7-- 
SELECT town_id , `name` from towns WHERE LEFT(`name`, 1)NOT IN('r','d','B') ORDER BY `name`;

#Exercise --8--
CREATE VIEW v_employees_hired_after_2000 AS
SELECT `first_name`, `last_name` from employees where YEAR( hire_date )> 2000;
SELECT * from v_employees_hired_after_2000;

#Exercise --9--
SELECT `first_name`,`last_name` from employees WHERE char_length(`last_name`) = 5;

#Exercise --10--
SELECT `country_name`,`iso_code` from countries WHERE `country_name` LIKE '%a%a%a%' ORDER BY iso_code; 

#Exercise --11-- 
SELECT `peak_name`,`river_name`,lower(concat(`peak_name`, SUBSTRING(`river_name`,2))) as 'mix'
from peaks as p JOIN `rivers` as r 
ON right(`peak_name`,1) = left(`river_name`, 1) ORDER BY mix; 

#Exercise --12-- 
SELECT `name`, date_format(`start`,'%Y-%m-%d') as 'start' from `games` WHERE year(`start`) IN (2011,2012)
ORDER BY `start`,`name` limit 50;

#Exercise --13-- 
SELECT `user_name`, substr(`email`, locate('@',`email`) +1) as 'Email Provider' from users ORDER BY `Email Provider`, `user_name`;

#Exercise --14--
SELECT user_name, ip_address from users where ip_address LIKE "___.1%.%.___" ORDER BY user_name	asc;

#Exercise --15--
SELECT `name` as `game`, 
 (CASE 
     WHEN HOUR (`start`) between 0 and 11 then 'Morning'
     When HOUR (`start`) BETWEEN 12 and 17 then 'Afternoon'
     ELSE 'Evening'    END) as 'Part of the day' ,
     
     (CASE  When `duration` <= 3 then 'Extra Short'
     WHEN `duration` BETWEEN 3 and 6 THEN 'Short'
     WHEN `duration` BETWEEN 6 and 10 THEN 'Long'
     ELSE 'Extra Long'  END) as 'Durantion'
     
     from games;
     
     #Exercise --16-- 
	 SELECT `product_name`, `order_date`,
    ADDDATE(`order_date`, INTERVAL 3 DAY) AS 'pay_due',
    ADDDATE(`order_date`, INTERVAL 1 MONTH) AS 'deliver_due'
FROM `orders`;
     