

CREATE SCHEMA fsd;

CREATE TABLE countries(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL
);


CREATE TABLE towns(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
`country_id` INT ,
CONSTRAINT fk_countrie_towns 
FOREIGN KEY (`country_id`) 
REFERENCES countries(id) 
);


CREATE TABLE stadiums(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
`capacity` INT NOT NULL,
`town_id` INT NOT NULL,
CONSTRAINT fk_towns_staduims 
FOREIGN KEY (`town_id`) 
REFERENCES towns(id) 
);


CREATE TABLE teams(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
`established` DATE NOT NULL,
`fan_base` BIGINT NOT NULL DEFAULT 0,
`stadium_id` INT NOT NULL,
CONSTRAINT fk_staduims_teams 
FOREIGN KEY (`stadium_id`) 
REFERENCES stadiums(id) 
);


CREATE TABLE skills_data(
id INT PRIMARY KEY AUTO_INCREMENT,
dribbling INT DEFAULT 0,
pace INT DEFAULT 0,
passing INT DEFAULT 0,
shooting INT DEFAULT 0,
speed INT DEFAULT 0,
strength INT DEFAULT 0
);


CREATE TABLE coaches(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR (20) NOT NULL,
`salary` DECIMAL (10,2) NOT NULL DEFAULT 0, 
coach_level INT NOT NULL DEFAULT 0 
);


CREATE TABLE players(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR (20) NOT NULL,
age INT NOT NULL DEFAULT 0,
`position` CHAR(1) NOT NULL, 
`salary` DECIMAL (10,2) NOT NULL DEFAULT 0, 
 hire_date DATETIME ,
 skills_data_id INT NOT NULL ,
 team_id INT ,
 
 CONSTRAINT fk_skills_data_players 
 FOREIGN KEY (`skills_data_id`)
 REFERENCES skills_data(id),
 
 CONSTRAINT fk_teams_players
 FOREIGN KEY (`team_id`) 
 REFERENCES teams(id)
);


CREATE TABLE players_coaches(
player_id INT,
coach_id INT, 
 
 CONSTRAINT fk_players_coaches_player 
 FOREIGN KEY (`player_id`)
 REFERENCES players(id),
 
 CONSTRAINT fk_players_coaches_coach
 FOREIGN KEY (`coach_id`) 
 REFERENCES coaches(id)
);


# ALREADY INSERT THE DATA IN TABLES 
# EXERCISE --2--- INSERT
 INSERT into coaches (`first_name`, `last_name`, `salary` ,`coach_level`)
(SELECT 
	`first_name`,`last_name`,`salary`*2 ,char_length(`first_name`) as `coach_level`
    FROM players WHERE age >= 45);
    
    SELECT * FROM coaches;
    
#Exercise --3-- UPDATE
UPDATE `coaches` as c 
SET `coach_level` = `coach_level`  + 1
WHERE 
	`first_name` LIKE 'A%'
    AND  (SELECT count(*) 
    FROM players_coaches as pc
    WHERE pc.coach_id = c.id) >0;
    
    SELECT * from coaches where first_name LIKE 'A%';
    
#SECOND WAY ------------------------
 UPDATE coaches 
 JOIN  players_coaches as pc ON pc.coach_id = coaches.id 
 SET coach_level = coach_level + 1 
 WHERE first_name LIKE 'A%';
 
 #Exercise --4--- DELETE
 
 DELETE FROM players WHERE age >= 45;
 
 # PART III QUERING
 
 #Exercise --5-- 
 SELECT p.`first_name`,p.`age`,p.`salary` from players as p
 ORDER BY p.`salary` desc;
 
 #Exercise --6-- 
 SELECT p.`id`, concat_ws(' ', first_name, last_name) as 'full_name', p.age, p.`position`,p.`hire_date` from players as p
 JOIN `skills_data` as s ON p.`skills_data_id` = s.id
 WHERE p.`age` < 23 AND p.`position` like ('A%') AND p.`hire_date` IS NULL AND s.strength > 50 
 ORDER BY salary asc , age;
 
 #Exercise --7-- 
 SELECT t.`name` as `team_name` , t.`established`,t.`fan_base`, count(p.`id`) as `players_count`
 FROM teams as t 
 LEFT JOIN players as p ON t.`id` = p.`team_id`
 GROUP BY t.`id`
 ORDER BY `players_count` DESC , t.`fan_base` desc; 
 
 #Exericise --8-- 
 SELECT max(`speed`) as `max_speed`, tw.`name` as 'town_name'
 FROM skills_data as sd 
	RIGHT JOIN `players` as p ON sd.`id` = p.`skills_data_id` 
    RIGHT JOIN `teams` as t ON p.`team_id` = t.`id`
    RIGHT JOIN `stadiums` as s ON t.`stadium_id` = s.`id`
    RIGHT JOIN `towns` as tw ON s.`town_id` = tw.`id` 
WHERE t.`name` != 'Devify'
 GROUP BY tw.`id`
 ORDER BY `max_speed`desc ,tw.`name`;
 
 #Exercise --9--
 
 SELECT 
    co.`name`,
    COUNT(pla.`id`) AS `total_count_of_players`,
    SUM(pla.`salary`) AS `total_sum_of_salaries`
FROM
    `players` AS pla
        RIGHT JOIN
    `teams` AS tea ON pla.`team_id` = tea.`id`
        RIGHT JOIN
    `stadiums` AS stad ON tea.`stadium_id` = stad.`id`
        RIGHT JOIN
    `towns` AS tws ON stad.`town_id` = tws.`id`
        RIGHT JOIN
    `countries` AS co ON tws.`country_id` = co.`id`
GROUP BY co.`name`
ORDER BY total_count_of_players DESC , co.`name`;

#Exercise --10-- PROGRAMABILITY 

DELIMITER $$ 
CREATE FUNCTION udf_stadium_players_count(stadium_name VARCHAR(30)) 
RETURNS INT 
DETERMINISTIC
BEGIN 
	RETURN(
    SELECT count(*) from `players` as p 
   LEFT JOIN `teams` as t ON p.`team_id` = t.`id`
   LEFT JOIN `stadiums` as s ON t.`stadium_id` = s.`id`
    WHERE s.`name` = stadium_name
);
    end $$ 
    
    #Exercise --11-- 
    
    DELIMITER $$

CREATE PROCEDURE udp_find_playmaker(min_dribble_points INT, team_name VARCHAR(45))
BEGIN
    SELECT 
    CONCAT(p.`first_name`, ' ', p.`last_name`) AS `full_name`,
    p.`age`,
    p.`salary`,
    sd.`dribbling`,
    sd.`speed`,
    t.`name`
FROM
    `players` AS p
        RIGHT JOIN
    `skills_data` AS sd ON p.`skills_data_id` = sd.`id`
        RIGHT JOIN
    `teams` AS t ON p.`team_id` = t.`id`
WHERE
    sd.`dribbling` > min_dribble_points
        AND t.`name` = team_name
        AND sd.`speed` > (SELECT AVG(speed) FROM `skills_data`)
ORDER BY sd.`speed` DESC
LIMIT 1;

END $$

CALL udp_find_playmaker (20, ‘Skyble’);
    
