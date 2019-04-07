/*
Version 1.0 - Mod: Spencer Woodfork
*/

/*

TABLE CREATION

*/


CREATE TABLE Bill (
	bill_id INT NOT NULL AUTO_INCREMENT,
	session INT,
	type VARCHAR(100),
    number INT,
    updated DATE,
    PRIMARY KEY (bill_id)
);

CREATE TABLE state(
	bill_id INT,
    state VARCHAR(100),
    date DATE,
    INDEX (bill_id),
    FOREIGN KEY (bill_id)
		REFERENCES bill(bill_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE sponsor(
	bill_id INT,
    name VARCHAR(100),
    party VARCHAR(100),
    state VARCHAR(100),
    INDEX (bill_id),
    FOREIGN KEY (bill_id)
		REFERENCES bill(bill_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE cosponsor(
	bill_id INT,
    name VARCHAR(100),
    party VARCHAR(100),
    state VARCHAR(100),
    joined DATE,
    INDEX (bill_id),
    FOREIGN KEY (bill_id)
		REFERENCES bill(bill_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE action(
	bill_id INT,
    date DATE,
    text VARCHAR(1000),
    ref VARCHAR(100),
    label VARCHAR(100),
    how VARCHAR(100),
    type VARCHAR(100),
    location VARCHAR(100),
    result VARCHAR(100),
    state VARCHAR(100),
	INDEX (bill_id),
    FOREIGN KEY (bill_id)
		REFERENCES bill(bill_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;


/*

STORED PROCEDURE CREATION

*/

# Switch delimiter to //, so query will execute line by line.
DELIMITER //
CREATE PROCEDURE insert_bill (IN session INT, IN type VARCHAR(100), IN number INT, IN updated DATE)
BEGIN
	INSERT INTO bill (session, type, number, updated) values (session, type, number, updated);
    SELECT MAX(bill_ID) FROM BILL;
END

# Switch delimiter to //, so query will execute line by line.
DELIMITER //
CREATE PROCEDURE insert_state (IN bill_id INT, IN state VARCHAR(100), IN date DATE)
BEGIN
	INSERT INTO state (bill_id, state, date) values (bill_id, state, date);
END

# Switch delimiter to //, so query will execute line by line.
DELIMITER //
CREATE PROCEDURE insert_action (IN bill_id INT, IN date DATE, IN text VARCHAR(1000), IN ref VARCHAR(100), IN label VARCHAR(100), IN how VARCHAR(100), 
	IN type VARCHAR(100), IN location VARCHAR(100), IN result VARCHAR(100), IN state VARCHAR(100))
BEGIN
	INSERT INTO action (bill_id, date, text, ref, label, how, type, location, result, state) values (bill_id, date, text, ref, label, how, type, location, result, state);
END

# Switch delimiter to //, so query will execute line by line.
DELIMITER //
CREATE PROCEDURE insert_sponsor (IN bill_id INT, IN name VARCHAR(100), IN party VARCHAR(100), IN state VARCHAR(100))
BEGIN
	INSERT INTO sponsor (bill_id, name, party, state) values (bill_id, name, party, state);
END

# Switch delimiter to //, so query will execute line by line.
DELIMITER //
CREATE PROCEDURE insert_cosponsor (IN bill_id INT, IN name VARCHAR(100), IN party VARCHAR(100), IN state VARCHAR(100), IN joined DATE)
BEGIN
	INSERT INTO cosponsor (bill_id, name, party, state, joined) values (bill_id, name, party, state, joined);
END

/*

DROP STATEMENTS:

DROP TABLE action;
DROP TABLE cosponsor;
DROP TABLE sponsor;
DROP TABLE STATE;
DROP TABLE BILL;

DROP PROCEDURE insert_action;
DROP PROCEDURE insert_bill;
DROP PROCEDURE  insert_cosponsor;
DROP PROCEDURE insert_sponsor;
DROP PROCEDURE insert_state;

*/