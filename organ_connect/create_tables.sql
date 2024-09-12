CREATE DATABASE ORGAN_CONNECT;
USE ORGAN_CONNECT;

CREATE TABLE login(
    username VARCHAR(20) NOT NULL,
    password VARCHAR(20) NOT NULL
);

INSERT INTO login VALUES ('admin','admin');

#table 1
CREATE TABLE User(
    User_ID int NOT NULL,
    Name varchar(20) NOT NULL,
    Date_of_Birth date NOT NULL,
    Medical_insurance int,
    Medical_history varchar(20),
    Street varchar(20),
    City varchar(20),
    State varchar(20),
    PRIMARY KEY(User_ID)
);

#table 2
CREATE TABLE User_phone_no(
    User_ID int NOT NULL,
    phone_no varchar(15),
    FOREIGN KEY(User_ID) REFERENCES User(User_ID) ON DELETE CASCADE
);

#table 3
CREATE TABLE Organization(
  Organization_ID int NOT NULL,
  Organization_name varchar(20) NOT NULL,
  Location varchar(20),
  Government_approved int, # 0 or 1
  PRIMARY KEY(Organization_ID)
);

#table 4
CREATE TABLE Doctor(
  Doctor_ID int NOT NULL,
  Doctor_Name varchar(20) NOT NULL,
  Department_Name varchar(20) NOT NULL,
  organization_ID int NOT NULL,
  FOREIGN KEY(organization_ID) REFERENCES Organization(organization_ID) ON DELETE CASCADE,
  PRIMARY KEY(Doctor_ID)
);

#table 5
CREATE TABLE Patient(
    Patient_ID int NOT NULL,
    organ_req varchar(20) NOT NULL,
    reason_of_procurement varchar(20),
    Doctor_ID int NOT NULL,
    User_ID int NOT NULL,
    FOREIGN KEY(User_ID) REFERENCES User(User_ID) ON DELETE CASCADE,
    FOREIGN KEY(Doctor_ID) REFERENCES Doctor(Doctor_ID) ON DELETE CASCADE,
    PRIMARY KEY(Patient_Id, organ_req)
);

#table 6
CREATE TABLE Donor(
  Donor_ID int NOT NULL,
  organ_donated varchar(20) NOT NULL,
  reason_of_donation varchar(20),
  Organization_ID int NOT NULL,
  User_ID int NOT NULL,
  FOREIGN KEY(User_ID) REFERENCES User(User_ID) ON DELETE CASCADE,
  FOREIGN KEY(Organization_ID) REFERENCES Organization(Organization_ID) ON DELETE CASCADE,
  PRIMARY KEY(Donor_ID, organ_donated)
);

#table 7
CREATE TABLE Organ_available(
  Organ_ID int NOT NULL AUTO_INCREMENT,
  Organ_name varchar(20) NOT NULL,
  Donor_ID int NOT NULL,
  FOREIGN KEY(Donor_ID) REFERENCES Donor(Donor_ID) ON DELETE CASCADE,
  PRIMARY KEY(Organ_ID)
);

#table 8
CREATE TABLE Transaction(
  Patient_ID int NOT NULL,
  Organ_ID int NOT NULL,
  Donor_ID int NOT NULL,
  Date_of_transaction date NOT NULL,
  Status int NOT NULL, #0 or 1
  FOREIGN KEY(Patient_ID) REFERENCES Patient(Patient_ID) ON DELETE CASCADE,
  FOREIGN KEY(Donor_ID) REFERENCES Donor(Donor_ID) ON DELETE CASCADE,
  PRIMARY KEY(Patient_ID,Organ_ID)
);

#table 9
CREATE TABLE Organization_phone_no(
  Organization_ID int NOT NULL,
  Phone_no varchar(15),
  FOREIGN KEY(Organization_ID) REFERENCES Organization(Organization_ID) ON DELETE CASCADE
);

#table 10
CREATE TABLE Doctor_phone_no(
  Doctor_ID int NOT NULL,
  Phone_no varchar(15),
  FOREIGN KEY(Doctor_ID) REFERENCES Doctor(Doctor_ID) ON DELETE CASCADE
);

#table 11
CREATE TABLE Organization_head(
  Organization_ID int NOT NULL,
  Employee_ID int NOT NULL,
  Name varchar(20) NOT NULL,
  Date_of_joining date NOT NULL,
  Term_length int NOT NULL,
  FOREIGN KEY(Organization_ID) REFERENCES Organization(Organization_ID) ON DELETE CASCADE,
  PRIMARY KEY(Organization_ID,Employee_ID)
);
--
-- delimiter //
-- create trigger ADD_DONOR
-- after insert
-- on Donor
-- for each row
-- begin
-- insert into Organ_available(Organ_name, Donor_ID)
-- values (new.organ_donated, new.Donor_ID);
-- end//
-- delimiter ;
--
-- delimiter //
-- create trigger REMOVE_ORGAN
-- after insert
-- on Transaction
-- for each row
-- begin
-- delete from Organ_available
-- where Organ_ID = new.Organ_ID;
-- end//
-- delimiter ;

create table log (
  querytime datetime,
  comment varchar(255)
);

delimiter //
create trigger ADD_DONOR_LOG
after insert
on Donor
for each row
begin
insert into log values
(now(), concat("Inserted new Donor", cast(new.Donor_Id as char)));
end //

create trigger UPD_DONOR_LOG
after update
on Donor
for each row
begin
insert into log values
(now(), concat("Updated Donor Details", cast(new.Donor_Id as char)));
end //

delimiter //
create trigger DEL_DONOR_LOG
after delete
on Donor
for each row
begin
insert into log values
(now(), concat("Deleted Donor ", cast(old.Donor_Id as char)));
end //

create trigger ADD_PATIENT_LOG
after insert
on Patient
for each row
begin
insert into log values
(now(), concat("Inserted new Patient ", cast(new.Patient_Id as char)));
end //

create trigger UPD_PATIENT_LOG
after update
on Patient
for each row
begin
insert into log values
(now(), concat("Updated Patient Details ", cast(new.Patient_Id as char)));
end //

create trigger DEL_PATIENT_LOG
after delete
on Donor
for each row
begin
insert into log values
(now(), concat("Deleted Patient ", cast(old.Donor_Id as char)));
end //

create trigger ADD_TRASACTION_LOG
after insert
on Transaction
for each row
begin
insert into log values
(now(), concat("Added Transaction :: Patient ID : ", cast(new.Patient_ID as char), "; Donor ID : " ,cast(new.Donor_ID as char)));
end //



--Retrieve information about patients along with their associated doctors:

SELECT p.*, d.Doctor_ID, d.Doctor_Name, d.Department_Name
FROM Patient p
INNER JOIN Doctor d ON p.Doctor_ID = d.Doctor_ID;
--Get details of donors along with their associated organizations:
SELECT d.*, o.Organization_ID, o.Organization_name
FROM Donor d
INNER JOIN Organization o ON d.Organization_ID = o.Organization_ID;
-- Fetch all transactions along with patient and donor information:
SELECT t., p., d.*
FROM Transaction t
INNER JOIN Patient p ON t.Patient_ID = p.Patient_ID
INNER JOIN Donor d ON t.Donor_ID = d.Donor_ID;
--Retrieve information about organizations along with their heads:
SELECT o.*, oh.Employee_ID, oh.Name AS Head_Name, oh.Date_of_joining AS Head_Joining_Date
FROM Organization o
INNER JOIN Organization_head oh ON o.Organization_ID = oh.Organization_ID;



-- cursors 
 DELIMITER //
 CREATE PROCEDURE get_donor()
     BEGIN
        DECLARE done INT DEFAULT FALSE;
         DECLARE donor_id INT;
         DECLARE organ_donated VARCHAR(20);
         DECLARE cur CURSOR FOR SELECT Donor_ID, organ_donated FROM Donor;
         DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
         OPEN cur;
         read_loop: LOOP
             FETCH cur INTO donor_id, organ_donated;
             -- Inside the loop
                  SELECT CONCAT('Donor ID: ', donor_id, ', Organ Donated: ', organ_donated);

             IF done THEN
                 LEAVE read_loop;
             END IF;
             -- Process retrieved data here
             -- For example, you can print or manipulate the data
             SELECT CONCAT('Donor ID: ', donor_id, ', Organ Donated: ', organ_donated);
         END LOOP;
         CLOSE cur;
     END //