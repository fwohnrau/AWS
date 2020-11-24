-- CREATE USER 'awsuser'@'localhost' IDENTIFIED BY 'awssecret';
-- GRANT ALL PRIVILEGES ON test_db.* to 'awsuser'@'localhost';
CREATE TABLE Details (id MEDIUMINT NOT NULL AUTO_INCREMENT, lastname VARCHAR(20), firstname VARCHAR(20), email VARCHAR(50), primary key (id));