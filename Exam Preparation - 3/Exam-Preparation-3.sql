drop SCHEMA sgd;
CREATE SCHEMA sgd;

CREATE TABLE addresses (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL
);

CREATE TABLE `categories`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(10) NOT NULL
);

CREATE TABLE offices(
`id` INT  PRIMARY KEY AUTO_INCREMENT,
`workspace_capacity` INT NOT NULL,
`website` VARCHAR(50) ,
`address_id` INT NOT NULL,

CONSTRAINT fk_offices_addresses 
FOREIGN KEY (`address_id`)
REFERENCES `addresses`(id)
);

CREATE TABLE employees (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(30) NOT NULL,
`last_name` VARCHAR(30) NOT NULL,
`age` INT NOT NULL,
`salary` DECIMAL (10,2) NOT NULL,
`job_title` VARCHAR(20) NOT NULL,
`happiness_level` CHAR(1) NOT NULL
);



CREATE TABLE teams(
`id` INT  PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL,
`office_id` INT NOT NULL,
`leader_id` INT UNIQUE ,

CONSTRAINT fk_employees_team 
FOREIGN KEY (`leader_id`)
REFERENCES `employees`(id),

CONSTRAINT fk_offices_team 
FOREIGN KEY (`office_id`)
REFERENCES `offices`(id)
);

CREATE TABLE games(
`id` INT AUTO_INCREMENT PRIMARY KEY,
`name` VARCHAR(50) NOT NULL UNIQUE,
`description` TEXT ,
`rating` FLOAT NOT NULL DEFAULT 5.5 ,
`budget` DECIMAL (10,2) NOT NULL,
`release_date` DATE,
`team_id` INT NOT NULL ,

CONSTRAINT fk_games_teams 
FOREIGN KEY (`team_id`)
REFERENCES `teams`(id)
);

CREATE TABLE games_categories(
`game_id` INT NOT NULL,
`category_id` INT NOT NULL,

CONSTRAINT pk_games_categories 
PRIMARY KEY (`game_id`, `category_id`),

CONSTRAINT fk_games_games_categories 
FOREIGN KEY (`game_id`)
REFERENCES `games`(id),

CONSTRAINT fk_categories_games_categories 
FOREIGN KEY (`category_id`) 
REFERENCES `categories`(id)
);


#PART II 
#Exercise --2-- INSERT

INSERT INTO `games` (`name`,`rating`,`budget`,`team_id`)
(SELECT reverse(lower(substr(t.`name`,2))), t.`id`, t.`leader_id` * 1000, t.`id`
	FROM `teams` as t 
    WHERE t.`id` BETWEEN 1 AND 9); 

#Exercise --3-- UPDATE 
UPDATE `employees` 
SET 
    `salary` = `salary` + 1000
WHERE
    `age` < 40 AND `salary` <= 5000
        AND (`id` IN (SELECT 
            `id`
        FROM
            teams));
            
            SELECT * from employees;

#Exercise --4-- DELETE 

DELETE `games` FROM `games`
        LEFT JOIN
    `games_categories` ON games.`id` = games_categories.`game_id` 
WHERE
    `category_id` IS NULL
    AND `release_date` IS NULL;

#Exercise --5-- 
SELECT e.`first_name`,e.`last_name`,e.`age`,e.`salary`,e.`happiness_level` from employees as e
ORDER BY e.`salary`, e.`id`;

#Exercise --6--
SELECT t.`name` as `team_name` ,a.`name` as `address_name` , char_length(a.`name`) as `count_of_characters` from `addresses` as a 
JOIN `offices` as o ON a.id = o.address_id 
JOIN `teams` as t ON t.office_id = o.id
	WHERE o.website IS NOT NULL 
   ORDER BY `team_name`, `address_name`;
   
#Exercise --7-- 
    SELECT 
    c.`name`,
    COUNT(g.`id`) AS `games_count`,
    ROUND(AVG(g.`budget`), 2) AS `avg_budget`,
    MAX(g.`rating`) AS `max_rating`
FROM
    `categories` AS c
        JOIN
    `games_categories` AS gc ON c.`id` = gc.`category_id`
        JOIN
    `games` AS g ON gc.`game_id` = g.`id`
GROUP BY c.`name`
HAVING `max_rating` >= 9.5
ORDER BY `games_count` DESC , c.`name`;

#Exercise --8-- 
SELECT 
    g.`name`,
    g.`release_date`,
    CONCAT(SUBSTR(g.`description`, 1, 10), '...') AS `summary`,
    (CASE
        WHEN MONTH(g.`release_date`) IN (1 , 2, 3) THEN 'Q1'
        WHEN MONTH(g.`release_date`) IN (4 , 5, 6) THEN 'Q2'
        WHEN MONTH(g.`release_date`) IN (7 , 8, 9) THEN 'Q3'
        WHEN MONTH(g.`release_date`) IN (10 , 11, 12) THEN 'Q4'
    END) AS `quater`,
    t.`name`
FROM
    `games` AS g
        JOIN
    `teams` AS t ON g.`team_id` = t.`id`
WHERE
    YEAR(g.`release_date`) = 2022
        AND MONTH(g.`release_date`) % 2 = 0
        AND RIGHT(g.`name`, 1) = 2
ORDER BY `quater`;

#Exercise --9-- 
SELECT 
    g.`name`,
    IF(g.`budget` < 50000,
        'Normal budget',
        'Insufficient budget') AS `budget_level`,
    t.`name`,
    a.`name`
FROM
    `games` AS g
        JOIN
    `teams` AS t ON g.`team_id` = t.`id`
        JOIN
    `offices` AS o ON t.`office_id` = o.`id`
        JOIN
    `addresses` AS a ON o.`address_id` = a.`id`
        LEFT JOIN
    `games_categories` AS gc ON g.`id` = gc.`game_id`
WHERE
    g.`release_date` IS NULL
        AND gc.`category_id` IS NULL
ORDER BY g.`name`;

#Exercise --10-- 

DELIMITER $$ 
CREATE FUNCTION  udf_game_info_by_name (game_name VARCHAR (20))
RETURNS TEXT
DETERMINISTIC
BEGIN
    RETURN (SELECT 
        CONCAT_WS(' ',
                'The',
                g.`name`,
                'is developed by a',
                t.`name`,
                'in an office with an address',
                a.`name`)
        FROM
            `games` AS g
                JOIN
            `teams` AS t ON g.`team_id` = t.`id`
                JOIN
            `offices` AS o ON t.`office_id` = o.`id`
                JOIN
            `addresses` AS a ON o.`address_id` = a.`id`
        WHERE
            g.`name` = game_name);
            END $$
            
        SELECT UDF_GAME_INFO_BY_NAME('Bitwolf') AS info;    
        
        #Exercise --11-- 
        
        
 

DELIMITER $$
CREATE PROCEDURE udp_update_budget(min_game_rating FLOAT)
BEGIN
UPDATE `games` 
    SET 
        `budget` = `budget` + 100000,
        `release_date` = DATE_ADD(`release_date`,
            INTERVAL 1 YEAR)
    WHERE
        games.id NOT IN (SELECT game_id FROM games_categories)
            AND games.rating > min_game_rating
            AND games.release_date IS NOT NULL;
END $$

CALL udp_update_budget(8);