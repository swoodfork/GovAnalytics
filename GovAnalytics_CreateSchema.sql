/*
Version 1.1 - Mod: Spencer Woodfork
Version 1.2 - Mod: Katie Ryan
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

CREATE TABLE History (
	hist_id INT NOT NULL AUTO_INCREMENT,
	yr INT,
    house varchar(20),
	Pres_Party VARCHAR(20),
    Majority_Party VARCHAR(20),
    D_Net_Change INT,
    R_Net_Change INT,
    D_Total_Seat INT,
    R_Total_Seat INT,
    Ind_Total_Seat INT,
    PRIMARY KEY (hist_id)
);

/*
VIEW CREATION
*/

Create View bill_Summary
as
SELECT b.bill_id
, b.session
, b.type
, b.number
, case trim(party) when "Republican" then 1 else 0 end as Spons_Rep_ind
, case trim(party) when "Democratic" then 1 else 0 end as Spons_Dem_ind
, case trim(party) when "Independent" then 1 else 0 end as Indep_ind
, case when st.state 
in ("ENACTED:SIGNED","PASSED:BILL","PASSED:CONCURRENTRES","PASSED:SIMPLERES","") 
then 1 else 0 end as Pass_Ind
, st.state 
, st.date

, case when trim(party) = "Republican" AND h1.Pres_Party = "Republican" then 1
when trim(party) = "Democratic" AND h1.Pres_Party = "Democrat" then 1 
else 0 end as Pres_Party_Match
, case when trim(party) = "Republican" AND h1.Majority_Party = "Republican" then 1
when trim(party) = "Democratic" AND h1.Majority_Party = "Democrat" then 1 
else 0 end as Senate_Party_Match
, case when trim(party) = "Republican" then h1.R_Total_Seat
when trim(party) = "Democratic" then h1.D_Total_Seat
when trim(party) = "Independent" then h1.Ind_Total_Seat
else null end as Num_Senators_In_Same_Party
, case when trim(party) = "Republican" AND h2.Majority_Party = "Republican" then 1
when trim(party) = "Democratic" AND h2.Majority_Party = "Democrat" then 1 
else 0 end as HouseOfR_Party_Match
, case when trim(party) = "Republican" then h2.R_Total_Seat
when trim(party) = "Democratic" then h2.D_Total_Seat
when trim(party) = "Independent" then h2.Ind_Total_Seat
else null end as Num_HouseOfR_In_Same_Party

FROM bill b
inner join sponsor s 
on b.bill_id = s.bill_id
inner join state st 
on b.bill_id = st.bill_id
inner join history h1
on h1.yr = year(st.date)
and h1.house = "Senate"
inner join history h2
on h2.yr = year(st.date)
and h2.house = "House of Rep"
;

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