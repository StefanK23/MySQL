drop schema instd;
create SCHEMA instd;
use instd;


CREATE TABLE photos(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`description` TEXT NOT NULL,
`date` DATETIME NOT NULL,
`views` INT NOT NULL DEFAULT 0
);

CREATE TABLE comments(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`comment` VARCHAR(255) NOT NULL,
`date` DATETIME NOT NULL,
`photo_id` INT NOT NULL,
CONSTRAINT fk_photos_comments 
FOREIGN KEY(`photo_id`)
REFERENCES  photos(id)
);



CREATE TABLE users (
`id` INT PRIMARY KEY ,
`username` VARCHAR(30) NOT NULL UNIQUE,
`password` VARCHAR(30) NOT NULL,
`email` VARCHAR(50) NOT NULL,
`gender` CHAR(1) NOT NULL,
`age` INT NOT NULL,
`job_title` VARCHAR(40) NOT NULL,
`ip` VARCHAR(30) NOT NULL
);

CREATE TABLE addresses (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`address` VARCHAR(30) NOT NULL,
`town` VARCHAR(30) NOT NULL,
`country` VARCHAR(30) NOT NULL,
`user_id` INT NOT NULL,

CONSTRAINT fk_users_addresses 
FOREIGN KEY (`user_id`)
REFERENCES `users`(id)
);

CREATE TABLE `users_photos` (
`user_id` INT NOT NULL,
`photo_id` INT NOT NULL,

CONSTRAINT fk_users_users_photos 
FOREIGN KEY (`user_id`)
REFERENCES `users`(id), 

CONSTRAINT fk_photos_users_photos
FOREIGN KEY (`photo_id`)
REFERENCES `photos`(id)
);

CREATE TABLE `likes` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`photo_id` INT ,
`user_id` INT ,

CONSTRAINT fk_users_likes 
FOREIGN KEY (`user_id`)
REFERENCES `users`(id), 

CONSTRAINT fk_photos_likes
FOREIGN KEY (`photo_id`)
REFERENCES `photos`(id)
);

#PART II  
# Exercise --2-- INSERT 
INSERT INTO `addresses` (`address`,`town`,`country`,`user_id`)
(SELECT u.`username`,u.`password`,u.`ip`,u.`age` 
	FROM `users` as u 
	WHERE u.`gender` = 'M');  
    
#Exercise --3-- UPDATE 

 UPDATE `addresses` 
SET 
    `country` = CASE
        WHEN `country` LIKE 'B%' THEN 'Blocked'
        WHEN `country` LIKE 'T%' THEN 'Test'
        WHEN `country` LIKE 'P%' THEN 'In Progress'
        ELSE `country`
    END;

#Exercise --4-- DELETE 
 DELETE FROM `addresses` AS a
 WHERE  a.`id` % 3 = 0;
   
#PART III -------------------------------

#Exercise --5-- 
SELECT u.`username`,u.`gender`,u.`age` from `users` as u 
ORDER BY u.`age` desc, u.`username`asc;

#Exercise --6-- 
SELECT p.`id`,p.`date`,p.`description`, count(c.`id`) as `commentsCount` from photos as p 
JOIN `comments` as c ON p.`id` = c.`photo_id`
GROUP BY p.`id`
 ORDER BY `commentsCount` desc, p.`id` asc LIMIT 5;
 
 
 #Exercise --7-- 
 SELECT 
    CONCAT(u.`id`, ' ', u.`username`) AS `id_username`,
    u.`email`
FROM
    `users` AS u
        JOIN
    `users_photos` AS up ON u.`id` = up.`user_id`
        JOIN
    `photos` AS p ON up.`photo_id` = p.`id`
WHERE
    u.`id` = p.`id`
ORDER BY u.`id`;

#Exercise --8-- 
 
 SELECT ph.`id` , count(DISTINCT l.`id`) as `likes_count`, count(DISTINCT com.`id`) as `comments_count` 
 from photos as ph
 LEFT JOIN likes as l ON ph.id = l.photo_id
 LEFT JOIN comments as com ON ph.id= com.photo_id 
 group by ph.`id`
 ORDER BY `likes_count` desc, `comments_count` desc ,ph.`id`;

#Exercise --9--
 SELECT 
    CONCAT(LEFT(p.`description`, 30), '...') AS `summary`,
    p.`date`
FROM
    `photos` AS p
WHERE
    DAY(p.`date` )= 10
ORDER BY p.`date` DESC;

#Exercise --10-- 
DELIMITER $$  
CREATE FUNCTION 
udf_users_photos_count(username VARCHAR(30)) 
RETURNS	 INT
DETERMINISTIC 
BEGIN 
  RETURN (SELECT count(*)
	FROM `photos` as p 
     JOIN `users_photos` as up ON p.`id` = up.`user_id`
     JOIN `users` as u ON up.`user_id` = u.`id`
     WHERE u.`username`= username);
END
$$

SELECT udf_users_photos_count('ssantryd')

#Exercise --11--

DELIMITER $$

CREATE PROCEDURE udp_modify_user (address VARCHAR(30), town VARCHAR(30))
BEGIN
    UPDATE `users` 
SET 
    `age` = `age` + 10
WHERE
    EXISTS( SELECT 
            *
        FROM
            `addresses`
        WHERE
            `address` = address
                AND `town` = town);
END $$

CALL udp_modify_user ('97 Valley Edge Parkway', 'Divinópolis');
SELECT u.username, u.email,u.gender,u.age,u.job_title FROM users AS u
WHERE u.username = 'eblagden21';