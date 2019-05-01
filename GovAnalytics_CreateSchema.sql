/*
Version 1.0 - Mod: Spencer Woodfork
Version 1.1 - Mod: Katie Ryan
Version 1.2 - Mod: Spencer Woodfork - Added optimization improvements
*/

/*

TABLE CREATION

*/
DROP TABLE IF EXISTS history;

CREATE TABLE IF NOT EXISTS legislator (
	legislator_id INT NOT NULL AUTO_INCREMENT,
	bioguide VARCHAR(10),
    thomas VARCHAR(10),
	govtrack INT,
    icpsr INT,
    house_history INT,
    first VARCHAR(50),
    middle VARCHAR(50),
    last VARCHAR(50),
    birthday DATE,
    gender CHAR(10),
    PRIMARY KEY (legislator_id)
);

CREATE TABLE IF NOT EXISTS term(
	legislator_id INT,
    type VARCHAR(10),
    start DATE,
    end DATE,
    state VARCHAR(50),
    class INT,
    district INT,
    party VARCHAR(50),
    INDEX (legislator_id),
    FOREIGN KEY (legislator_id)
		REFERENCES legislator(legislator_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS bill (
	bill_id INT NOT NULL AUTO_INCREMENT,
	session INT,
	type VARCHAR(100),
    number INT,
    introduced DATE,
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
    legislator_id INT,
    name VARCHAR(100),
    party VARCHAR(100),
    state VARCHAR(100),
    INDEX (bill_id),
    FOREIGN KEY (bill_id)
		REFERENCES bill(bill_id)
        ON DELETE CASCADE,
	FOREIGN KEY (legislator_id)
		REFERENCES legislator(legislator_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cosponsor(
	bill_id INT,
	legislator_id INT,
    name VARCHAR(100),
    party VARCHAR(100),
    state VARCHAR(100),
    joined DATE,
    INDEX (bill_id),
    FOREIGN KEY (bill_id)
		REFERENCES bill(bill_id)
        ON DELETE CASCADE,
	FOREIGN KEY (legislator_id)
		REFERENCES legislator(legislator_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS action(
	bill_id INT,
    date DATE,
    text VARCHAR(5000),
    ref VARCHAR(500),
    label VARCHAR(100),
    how VARCHAR(100),
    type VARCHAR(100),
    location VARCHAR(100),
    result VARCHAR(100),
    state VARCHAR(100),
    committee VARCHAR(1000),
    in_committee VARCHAR(1000),
    subcommittee VARCHAR(1000),
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

CREATE TABLE IF NOT EXISTS committee(
	bill_id INT,
    committee VARCHAR(400),
    committee_id VARCHAR(50),
    subcommittee VARCHAR(400),
    subcommittee_id VARCHAR(50),
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
    PRIMARY KEY (Year)
);

/*
VIEW CREATION
*/

DROP VIEW IF EXISTS bill_summary;
DROP VIEW IF EXISTS bill_summary_ind;
DROP VIEW IF EXISTS bill_cosponsor;

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



CREATE VIEW bill_summary_ind
AS

SELECT b.bill_id AS bill_id

,b.session AS session

,b.type AS type

,b.number AS number

,s.party AS party

,st.state AS state

,(case when (st.state in ('ENACTED:SIGNED','PASSED:BILL','PASSED:CONCURRENTRES','PASSED:SIMPLERES','ENACTED:VETO_OVERRIDE')) then 1 else 0 end) AS Pass_Ind

,st.date AS date

,(case when ((trim(s.party) = 'Republican') and (hist.Pres_Party = 'Republican')) then 1 when ((trim(s.party) = 'Democratic') and (hist.Pres_Party = 'Democrat')) then 1 else 0 end) AS Pres_Party_Match

,(case when ((trim(s.party) = 'Republican') and (hist.Majority_Senate_Party = 'Republican')) then 1 when ((trim(s.party) = 'Democratic') and (hist.Majority_Senate_Party = 'Democrat')) then 1 else 0 end) AS Senate_Party_Match

,(case when (trim(s.party) = 'Republican') then (hist.Senate_R_Total_Seat / 100) when (trim(s.party) = 'Democrat') then (hist.Senate_D_Total_Seat / 100) when (trim(s.party) = 'Independent') then (hist.Senate_Ind_Total_Seat / 100) else NULL end) AS Prcnt_Senators_In_Same_Party

,(case when ((trim(s.party) = 'Republican') and (hist.Majority_House_Party = 'Republican')) then 1 when ((trim(s.party) = 'Democrat') and (hist.Majority_House_Party = 'Democrat')) then 1 else 0 end) AS HouseOfR_Party_Match

,(case when (trim(s.party) = 'Republican') then (hist.House_R_Total_Seat / 435) when (trim(s.party) = 'Democrat') then (hist.House_D_Total_Seat / 435) when (trim(s.party) = 'Independent') then (hist.House_Ind_Total_Seat / 435) else NULL end) AS Prcnt_HouseOfR_In_Same_Party

from (((bill b join sponsor s

on((b.bill_id = s.bill_id)))

join state st

on((b.bill_id = st.bill_id)))

join history hist

on((hist.Year = year(st.date))));


CREATE VIEW bill_cosponsor
AS
SELECT bill_id

, count(1) as CoSponsor_Count

, sum(case when party = "Republican" then 1 else 0 end) as Rep_Count

, sum(case when party = "Democratic" then 1 else 0 end) as Dec_Count

, abs(sum(case when party = "Republican" then 1 else 0 end) - sum(case when party = "Democratic" then 1 else 0 end))/count(1) as Partisan_ind

 from cosponsor

group by bill_id;

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
DROP PROCEDURE IF EXISTS insert_committee;
DROP PROCEDURE IF EXISTS insert_legislator;
DROP PROCEDURE IF EXISTS insert_term;
DROP PROCEDURE IF EXISTS legislator_count;

DELIMITER //
CREATE PROCEDURE insert_bill (IN session INT, IN type VARCHAR(100), IN number INT, IN introduced DATE, IN updated DATE)
BEGIN
	IF (SELECT COUNT(*) FROM bill b where b.session = session AND b.type = type AND b.number = number) = 0
    THEN
		INSERT INTO bill (session, type, number, introduced, updated) values (session, type, number, introduced, updated);
		SELECT MAX(bill_ID) FROM BILL;
	ELSE
		SELECT -1;
    END IF;
END;

CREATE PROCEDURE insert_state (IN bill_id INT, IN state VARCHAR(100), IN date DATE)
BEGIN
	INSERT INTO state (bill_id, state, date) values (bill_id, state, date);
END;

CREATE PROCEDURE insert_action (IN bill_id INT, IN date DATE, IN text VARCHAR(5000), IN ref VARCHAR(500), IN label VARCHAR(100), IN how VARCHAR(100),
	IN type VARCHAR(100), IN location VARCHAR(100), IN result VARCHAR(100), IN state VARCHAR(100), IN committee VARCHAR(1000), IN in_committee VARCHAR(1000), IN subcommittee VARCHAR(1000))
BEGIN
	INSERT INTO action (bill_id, date, text, ref, label, how, type, location, result, state, committee, in_committee, subcommittee)
    values (bill_id, date, text, ref, label, how, type, location, result, state, committee, in_committee, subcommittee);
END;

CREATE PROCEDURE insert_sponsor (IN bill_id INT, IN bioguide VARCHAR(10), IN thomas VARCHAR(10), IN govtrack INT)
BEGIN
	IF bioguide IS NOT NULL
    THEN
		INSERT INTO sponsor (bill_id, legislator_id, name, party, state)
        SELECT bill_id, l.legislator_id, legislator_full_name(l.legislator_id), t.party, t.state
        FROM legislator l
        inner join term t on l.legislator_id = t.legislator_id
        inner join bill b on b.bill_id = bill_id
        WHERE l.bioguide = bioguide
        AND t.start <= b.introduced AND t.end >= b.introduced;
	ELSEIF thomas IS NOT NULL
    THEN
		INSERT INTO sponsor (bill_id, legislator_id, name, party, state)
        SELECT bill_id, l.legislator_id, legislator_full_name(l.legislator_id), t.party, t.state
        FROM legislator l
        inner join term t on l.legislator_id = t.legislator_id
		inner join bill b on b.bill_id = bill_id
        WHERE l.thomas = thomas
        AND t.start <= b.introduced AND t.end >= b.introduced;
	ELSEIF govtrack IS NOT NULL
    THEN
		INSERT INTO sponsor (bill_id, legislator_id, name, party, state)
        SELECT bill_id, l.legislator_id, legislator_full_name(l.legislator_id), t.party, t.state
        FROM legislator l
        inner join term t on l.legislator_id = t.legislator_id
		inner join bill b on b.bill_id = bill_id
        WHERE l.govtrack = govtrack
        AND t.start <= b.introduced AND t.end >= b.introduced;
	ELSE
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Sponsor could not be found with the provided IDs';
    END IF;
END;

CREATE PROCEDURE insert_cosponsor (IN bill_id INT, IN bioguide VARCHAR(10), IN thomas VARCHAR(10), IN govtrack INT, IN joined DATE)
BEGIN
	IF bioguide IS NOT NULL
    THEN
		INSERT INTO cosponsor (bill_id, legislator_id, name, party, state, joined)
        SELECT bill_id, l.legislator_id, legislator_full_name(l.legislator_id), t.party, t.state, joined
        FROM legislator l
        inner join term t on l.legislator_id = t.legislator_id
        inner join bill b on b.bill_id = bill_id
        WHERE l.bioguide = bioguide
        AND t.start <= b.introduced AND t.end >= b.introduced;
	ELSEIF thomas IS NOT NULL
    THEN
		INSERT INTO cosponsor (bill_id, legislator_id, name, party, state, joined)
        SELECT bill_id, l.legislator_id, legislator_full_name(l.legislator_id), t.party, t.state, joined
        FROM legislator l
        inner join term t on l.legislator_id = t.legislator_id
		inner join bill b on b.bill_id = bill_id
        WHERE l.thomas = thomas
        AND t.start <= b.introduced AND t.end >= b.introduced;
	ELSEIF govtrack IS NOT NULL
    THEN
		INSERT INTO cosponsor (bill_id, legislator_id, name, party, state, joined)
        SELECT bill_id, l.legislator_id, legislator_full_name(l.legislator_id), t.party, t.state, joined
        FROM legislator l
        inner join term t on l.legislator_id = t.legislator_id
		inner join bill b on b.bill_id = bill_id
        WHERE l.govtrack = govtrack
        AND t.start <= b.introduced AND t.end >= b.introduced;
	ELSE
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Cosponsor could not be found with the provided IDs';
    END IF;
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

CREATE PROCEDURE insert_committee (IN bill_id INT, IN committee VARCHAR(400), IN committee_id VARCHAR(50), IN subcommittee VARCHAR(400), IN subcommittee_id VARCHAR(10))
BEGIN
	INSERT INTO committee (bill_id, committee, committee_id, subcommittee, subcommittee_id)
    values (bill_id, committee, committee_id, subcommittee, subcommittee_id);
END;

CREATE PROCEDURE insert_legislator (IN bioguide VARCHAR(10), IN thomas VARCHAR(10), IN govtrack INT, IN icpsr INT, IN house_history INT, IN first VARCHAR(50),
	IN middle VARCHAR(50), IN last VARCHAR(50), IN birthday DATE, IN gender CHAR(10))
BEGIN
	INSERT INTO legislator (bioguide, thomas, govtrack, icpsr, house_history, first, middle, last, birthday, gender)
	values (bioguide, thomas, govtrack, icpsr, house_history, first, middle, last, birthday, gender);
	SELECT MAX(legislator_ID) FROM legislator;
END;

CREATE PROCEDURE insert_term (IN legislator_id INT, IN type VARCHAR(10), IN start DATE, IN end DATE, IN state VARCHAR(50), IN class INT, IN district INT, IN party VARCHAR(50))
BEGIN
	INSERT INTO term (legislator_id, type, start, end, state, class, district, party) values (legislator_id, type, start, end, state, class, district, party);
END;

CREATE PROCEDURE legislator_count()
BEGIN
	SELECT COUNT(*) FROM legislator;
END;

/*
CREATE FUNCTIONS
*/

DROP FUNCTION IF EXISTS legislator_full_name;

CREATE FUNCTION legislator_full_name (legislator_id int)
RETURNS VARCHAR(200)
READS SQL DATA
BEGIN

DECLARE	first VARCHAR(50);
DECLARE middle VARCHAR(50);
DECLARE last VARCHAR(50);
SELECT
	l.first, l.middle, l.last
    INTO
    first, middle, last
FROM legislator l
WHERE l.legislator_id = legislator_id;

IF middle IS NULL THEN
	RETURN CONCAT(first, ' ', last);
ELSE
	RETURN CONCAT(first, ' ', middle, ' ', LAST);
END IF;
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
DROP TABLE IF EXISTS committee;
DROP TABLE IF EXISTS bill;



DROP TABLE IF EXISTS term;
DROP TABLE IF EXISTS legislator;


DROP PROCEDURE insert_subject;
DROP PROCEDURE insert_title;
DROP PROCEDURE insert_action;
DROP PROCEDURE insert_bill;
DROP PROCEDURE insert_cosponsor;
DROP PROCEDURE insert_sponsor;
DROP PROCEDURE insert_state;
DROP PROCEDURE insert_summary;
DROP PROCEDURE insert_committee
DROP PROCEDURE insert_legislator;
DROP PROCEDURE insert_term;
DROP PROCEDURE legislator_count;

DROP FUNCTION IF EXISTS legislator_full_name;
*/