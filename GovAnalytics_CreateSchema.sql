/*
Version 1.0 - Mod: Spencer Woodfork
Version 1.1 - Mod: Katie Ryan
Version 1.2 - Mod: Spencer Woodfork - Added optimization improvements
*/

/*

TABLE CREATION

*/
DROP TABLE IF EXISTS history;

CREATE TABLE IF NOT EXISTS bill (
	bill_id INT NOT NULL AUTO_INCREMENT,
	session INT,
	type VARCHAR(100),
    number INT,
    updated DATE,
    PRIMARY KEY (bill_id)
);

CREATE TABLE IF NOT EXISTS state(
	bill_id INT,
    state VARCHAR(100),
    date DATE,
    INDEX (bill_id),
    FOREIGN KEY (bill_id)
		REFERENCES bill(bill_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sponsor(
	bill_id INT,
    name VARCHAR(100),
    party VARCHAR(100),
    state VARCHAR(100),
    INDEX (bill_id),
    FOREIGN KEY (bill_id)
		REFERENCES bill(bill_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cosponsor(
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

CREATE TABLE IF NOT EXISTS action(
	bill_id INT,
    date DATE,
    text VARCHAR(5000),
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

CREATE TABLE IF NOT EXISTS title(
	bill_id INT,
    type VARCHAR(100),
    title_as VARCHAR(100),
    text VARCHAR(2500),
    INDEX (bill_id),
    FOREIGN KEY (bill_id)
		REFERENCES bill(bill_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS subject(
	bill_id INT,
    name VARCHAR(1000),
    INDEX (bill_id),
    FOREIGN KEY (bill_id)
		REFERENCES bill(bill_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS summary(
	bill_id INT,
    date DATE,
    status VARCHAR(100),
    text MEDIUMTEXT,
    INDEX (bill_id),
    FOREIGN KEY (bill_id)
		REFERENCES bill(bill_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE History (
	Year YEAR,
	Pres_Party VARCHAR(20),
    Majority_House_Party VARCHAR(20),
    House_D_Net_Change INT,
    House_R_Net_Change INT,
    House_D_Total_Seat INT,
    House_R_Total_Seat INT,
    House_Ind_Total_Seat INT,
	Majority_Senate_Party VARCHAR(20),
	Senate_D_Net_Change INT,
    Senate_R_Net_Change INT,
    Senate_D_Total_Seat INT,
    Senate_R_Total_Seat INT,
    Senate_Ind_Total_Seat INT,
    INDEX (Year),
    PRIMARY KEY (Year)
) ENGINE=InnoDB;

/*
VIEW CREATION
*/

DROP VIEW IF EXISTS bill_summary;

CREATE VIEW bill_summary
AS
SELECT
	b.bill_id,
	b.session,
	b.type,
	b.number,
	s.party,
    st.state,
    st.date,
    hist.*
FROM bill b
inner join sponsor s on b.bill_id = s.bill_id
inner join state st on b.bill_id = st.bill_id
inner join history hist on hist.year = year(st.date);

/*

STORED PROCEDURE CREATION

*/

DROP PROCEDURE IF EXISTS insert_subject;
DROP PROCEDURE IF EXISTS insert_title;
DROP PROCEDURE IF EXISTS insert_action;
DROP PROCEDURE IF EXISTS insert_bill;
DROP PROCEDURE IF EXISTS insert_cosponsor;
DROP PROCEDURE IF EXISTS insert_sponsor;
DROP PROCEDURE IF EXISTS insert_state;
DROP PROCEDURE IF EXISTS insert_summary;

DELIMITER //
CREATE PROCEDURE insert_bill (IN session INT, IN type VARCHAR(100), IN number INT, IN updated DATE)
BEGIN
	INSERT INTO bill (session, type, number, updated) values (session, type, number, updated);
    SELECT MAX(bill_ID) FROM BILL;
END;

CREATE PROCEDURE insert_state (IN bill_id INT, IN state VARCHAR(100), IN date DATE)
BEGIN
	INSERT INTO state (bill_id, state, date) values (bill_id, state, date);
END;

CREATE PROCEDURE insert_action (IN bill_id INT, IN date DATE, IN text VARCHAR(5000), IN ref VARCHAR(100), IN label VARCHAR(100), IN how VARCHAR(100),
	IN type VARCHAR(100), IN location VARCHAR(100), IN result VARCHAR(100), IN state VARCHAR(100))
BEGIN
	INSERT INTO action (bill_id, date, text, ref, label, how, type, location, result, state) values (bill_id, date, text, ref, label, how, type, location, result, state);
END;

CREATE PROCEDURE insert_sponsor (IN bill_id INT, IN name VARCHAR(100), IN party VARCHAR(100), IN state VARCHAR(100))
BEGIN
	INSERT INTO sponsor (bill_id, name, party, state) values (bill_id, name, party, state);
END;

CREATE PROCEDURE insert_cosponsor (IN bill_id INT, IN name VARCHAR(100), IN party VARCHAR(100), IN state VARCHAR(100), IN joined DATE)
BEGIN
	INSERT INTO cosponsor (bill_id, name, party, state, joined) values (bill_id, name, party, state, joined);
END;

CREATE PROCEDURE insert_title (IN bill_id INT, in type VARCHAR(100), IN title_as VARCHAR(100), IN text VARCHAR(2500))
BEGIN
	INSERT INTO title (bill_id, type, title_as, text) values (bill_id, type, title_as, text);
END;

CREATE PROCEDURE insert_subject (IN bill_id INT, IN name VARCHAR(1000))
BEGIN
	INSERT INTO subject (bill_id, name) values (bill_id, name);
END;

CREATE PROCEDURE insert_summary (IN bill_id INT, IN date DATE, IN status VARCHAR(100), IN text MEDIUMTEXT)
BEGIN
	INSERT INTO summary (bill_id, date, status, text) values (bill_id, date, status, text);
END;



/*
DEFAULT DATA:
*/

INSERT INTO history
(	year,
    Pres_Party,
    Majority_House_Party,
    House_D_Net_Change,
    House_R_Net_Change,
    House_D_Total_Seat,
    House_R_Total_Seat,
    House_Ind_Total_Seat,
	Majority_Senate_Party,
    Senate_D_Net_Change,
    Senate_R_Net_Change,
    Senate_D_Total_Seat,
    Senate_R_Total_Seat,
    Senate_Ind_Total_Seat
)
VALUES
(1976, 'Republican', 'Democrat', 1,-1,292,143,0, 'Democrat', 0,1,61,38,1),
(1977, 'Republican', 'Democrat', 0,0,292,143,0, 'Democrat', 0,0,61,38,1),
(1978, 'Democrat', 'Democrat', -15,1,277,158,0, 'Democrat', -2,2,59,40,1),
(1979, 'Democrat', 'Democrat', 0,0,277,158,0, 'Democrat', -2,2,59,40,1),
(1980, 'Democrat', 'Democrat', -34,34,243,192,0, 'Republican', -12,12,46,53,1),
(1981, 'Democrat', 'Democrat', 0,0,243,192,0, 'Republican', 0,0,46,53,1),
(1982, 'Republican', 'Democrat', 26,-26,269,166,0, 'Republican', 1,0,46,54,0),
(1983, 'Republican', 'Democrat', 0,0,269,166,0, 'Republican', 0,0,46,54,0),
(1984, 'Republican', 'Democrat', -16,16,253,182,0, 'Republican', 2,-2,47,53,0),
(1985, 'Republican', 'Democrat', 0,0,253,182,0, 'Republican', 0,0,47,53,0),
(1986, 'Republican', 'Democrat', 5,-5,258,177,0, 'Democrat', 8,-8,55,45,0),
(1987, 'Republican', 'Democrat', 0,0,258,177,0, 'Democrat', 0,0,55,45,0),
(1988, 'Republican', 'Democrat', 2,-2,260,175,0, 'Democrat', 1,-1,55,45,0),
(1989, 'Republican', 'Democrat', 0,0,260,175,0, 'Democrat', 0,0,55,45,0),
(1990, 'Republican', 'Democrat', 7,-8,267,167,1, 'Democrat', 1,-1,56,44,0),
(1991, 'Republican', 'Democrat', 0,0,267,167,1, 'Democrat', 0,0,56,44,0),
(1992, 'Republican', 'Democrat', -9,9,258,176,1, 'Democrat', -1,1,56,44,0),
(1993, 'Republican', 'Democrat', 0,0,258,176,1, 'Democrat', 0,0,56,44,0),
(1994, 'Democrat', 'Republican', -54,54,204,230,1, 'Republican', -8,8,48,52,0),
(1995, 'Democrat', 'Republican', 0,0,204,230,1, 'Republican', 0,0,48,52,0),
(1996, 'Democrat', 'Republican', 2,-3,207,226,2, 'Republican', -2,2,45,55,0),
(1997, 'Democrat', 'Republican', 0,0,207,226,2, 'Republican', 0,0,45,55,0),
(1998, 'Democrat', 'Republican', 5,-4,211,223,1, 'Republican', 0,0,45,55,0),
(1999, 'Democrat', 'Republican', 0,0,211,223,1, 'Republican', 0,0,45,55,0),
(2000, 'Democrat', 'Republican', 1,-2,212,221,2, 'Democrat', 4,-4,50,50,0),
(2001, 'Democrat', 'Republican', 0,0,212,221,2, 'Democrat', 0,0,50,50,0),
(2002, 'Republican', 'Republican', -7,8,205,229,1, 'Republican', -1,2,48,51,1),
(2003, 'Republican', 'Republican', 0,0,205,229,1, 'Republican', 0,0,48,51,1),
(2004, 'Republican', 'Republican', -3,3,202,232,1, 'Republican', -4,4,44,55,1),
(2005, 'Republican', 'Republican', 0,0,202,232,1, 'Republican', 0,0,44,55,1),
(2006, 'Republican', 'Democrat', 32,-27,233,202,0, 'Democrat', 5,-6,49,49,2),
(2007, 'Republican', 'Democrat', 0,0,233,202,0, 'Democrat', 0,0,49,49,2),
(2008, 'Republican', 'Democrat', 21,-21,257,178,0, 'Democrat', 8,-8,57,41,2),
(2009, 'Republican', 'Democrat', 0,0,257,178,0, 'Democrat', 0,0,57,41,2),
(2010, 'Democrat', 'Republican', -63,63,193,242,0, 'Democrat', -6,6,51,47,2),
(2011, 'Democrat', 'Republican', 0,0,193,242,0, 'Democrat', 0,0,51,47,2),
(2012, 'Democrat', 'Republican', 8,-8,201,234,0, 'Democrat', 2,-2,53,45,2),
(2013, 'Democrat', 'Republican', 0,0,201,234,0, 'Democrat', 0,0,53,45,2),
(2014, 'Democrat', 'Republican', -13,13,188,247,0, 'Republican', 9,-9,44,54,2),
(2015, 'Democrat', 'Republican', 0,0,194,241,0, 'Republican', 0,0,44,54,2),
(2016, 'Democrat', 'Republican', -6,6,194,241,0, 'Republican', 2,-2,46,52,2),
(2017, 'Democrat', 'Republican', 0,0,194,241,0, 'Republican', 0,0,46,52,2),
(2018, 'Republican', 'Democrat', 41,-42,235,199,1, 'Republican', -2,2,45,53,2);


/*

DROP STATEMENTS:

DROP TABLE IF EXISTS history;
DROP TABLE IF EXISTS action;
DROP TABLE IF EXISTS cosponsor;
DROP TABLE IF EXISTS sponsor;
DROP TABLE IF EXISTS state;
DROP TABLE IF EXISTS title;
DROP TABLE IF EXISTS subject;
DROP TABLE IF EXISTS summary;
DROP TABLE IF EXISTS bill;


DROP PROCEDURE insert_subject;
DROP PROCEDURE insert_title;
DROP PROCEDURE insert_action;
DROP PROCEDURE insert_bill;
DROP PROCEDURE insert_cosponsor;
DROP PROCEDURE insert_sponsor;
DROP PROCEDURE insert_state;
DROP PROCEDURE insert_summary;
*/