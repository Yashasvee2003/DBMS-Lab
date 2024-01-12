/*
rem : Dropping Tables

DROP TABLE Car_Details;
DROP TABLE Car_Names;
DROP TABLE Model_Details;
DROP TABLE Car_Makers;
DROP TABLE Countries;
DROP TABLE Continents;

rem: dropping all views
DROP VIEW datsun_cars;
DROP VIEW car_list;
DROP VIEW european_makers;
DROP VIEW cars_count;


rem : Creation Of Tables

CREATE TABLE CONTINENTS(
ContID NUMBER(5) CONSTRAINT Primary_Key_CONTINETS PRIMARY KEY,
Continent VARCHAR2(15)
);


rem : Description of Continent Table


DESC CONTINENTS;





rem : Creation of Table COUNTRIES

CREATE TABLE COUNTRIES(
CountryID NUMBER(5) CONSTRAINT Primary_Key_COUNTRIES PRIMARY KEY ,
CountryName VARCHAR2(50),
ContID INT CONSTRAINT Foreign_Continent REFERENCES CONTINENTS(ContID)
);


rem : Description of Table COUNTRIES

DESC COUNTRIES;








rem : Creation of Table CAR_MAKERS

CREATE TABLE CAR_MAKERS(
Id Number(5) CONSTRAINT Primary_Key_CAR_MAKERS PRIMARY KEY,
Maker VARCHAR2(15),
FullName VARCHAR2(25),
CountryID CONSTRAINT Foreign_Key_CAR_MAKERS REFERENCES COUNTRIES(CountryID)
);

rem : Description of Table CAR_MAKERS

DESC COUNTRIES;






rem : Creation of Table MODEL_DETAILS


CREATE TABLE MODEL_DETAILS(
ModelId NUMBER(5) CONSTRAINT Primary_Key_ PRIMARY KEY,
MakerID NUMBER(5) CONSTRAINT Foreign_Key_MakerID REFERENCES CAR_MAKERS(Id),
Model VARCHAR2(25) CONSTRAINT Model_Name_Unique UNIQUE
);

rem : Description of Table MODEL_DETAILS

DESC MODEL_DETAILS;





rem : Creation of Table CAR_NAMES

CREATE TABLE CAR_NAMES(
Id NUMBER(5) CONSTRAINT Primary_Key_ID PRIMARY KEY,
Model VARCHAR2(25) CONSTRAINT Foreign_Key_Model REFERENCES MODEL_DETAILS(Model),
MakeDescription VARCHAR2(50)
);

rem : Describing Table

DESC CAR_NAMES;



rem : Creation of Table CAR_DETAILS

CREATE TABLE CAR_DETAILS(
ID NUMBER(5),
MPG NUMBER(5,2),
Cylinders NUMBER(5),
Edispl NUMBER(10),
Horsepower NUMBER(10),
Weight NUMBER(10),
Accelerate NUMBER(10,2),
Year NUMBER(5),
CONSTRAINT Primary_Key_ID_CAR_DETAILS PRIMARY KEY(ID),
CONSTRAINT Foreign_Key_ID FOREIGN KEY(ID) REFERENCES CAR_NAMES(ID)
);

rem : Describing Table CAR_DETAILS

DESC CAR_DETAILS;

rem : Insertion of Values into Tables

@ "C:\Users\vipur\ssn\sem 4\lab\DBMS\ex4\cars_new.sql";
*/

rem: 1)  Create a view named Datsun_Cars, which display the car id, model and descriptions of Datsun model

create or replace view Datsun_cars as(
select id, model, makedescription
from car_names
where model = 'datsun');

rem : displaying contents of view datsun_cars

select * from datsun_cars;

rem : checking the updatability of the view
rem : all should be in caps here

SELECT COLUMN_NAME, UPDATABLE
FROM USER_UPDATABLE_COLUMNS
WHERE TABLE_NAME = 'DATSUN_CARS' ;

rem : insertion

insert into datsun_cars values(
410, 'datsun', 'datsun 1234');

rem : checking if row is present in the table

select * from car_names where id = 410;

rem : updation of a value using primary key

update datsun_cars set
makedescription = 'datsun 4321'
where id = 410;

rem: checking if changes are reflected in base table and view

select * from car_names where id = 410;
select * from datsun_cars where id = 410;

rem : updation without using primary key

update datsun_cars set
makedescription = 'datsun 9876'
where makedescription = 'datsun 4321';

rem: checking if changes are reflected in base table and view

select * from car_names where id = 410;
select * from datsun_cars where id = 410;

rem : deleting changes made and displaying both view and base table
delete from datsun_cars where id = 410;
select * from car_names where id = 410;
select * from datsun_cars where id = 410;

rem : Since the primary key of the table is present in the view we can make all these changes




rem: **************************************************


rem: 2) Create a view called Car_List that shows the car id, model, description and
rem: operational parameters of all cars produced during 1974. Make surethat, the year
rem: should not be reassigned to any other value through view.


create or replace view car_list as(
select cn.id, cn.model, cn.makedescription,cd.cylinders, cd.edispl,  cd.year
from car_names cn
join car_details cd
on cn.id = cd.id
where cd.year = 1974) WITH CHECK OPTION;

rem : displaying contents of the view cars_list
select * from car_list;

rem: violation of condition resulting in an error
update car_list set year = 1970 where id = 159;

rem: inserting a tuple, not possible
insert into car_list values( 160, 'amc', 'amc bee', 12, 12.4, 1974);

rem: updating a tuple, possible as long as we dont update attribute value which is a foreign key
update car_list set cylinders = 10 where id = 135;

select * from car_list;
select * from car_details where id = 135;

rem : deleting a tuple, not possible as child record is found
delete from car_list where id = 135;




rem : **************************************************************

rem: 3) Create a view named European_Makers that will display the makername,
rem: full name and the country name of car makersfrom Europe.

create or replace view european_makers as(
select cm.maker, cm.fullname, c.countryname
from car_makers cm
join countries c
on cm.countryid = c.countryid
join continents con
on con.contid = c.contid
where con.continent = 'europe');

rem : displaying contents

select * from european_makers;

rem : checking for updatability
rem : only maker, fullname of maker are updatable as only that table is key preserved

SELECT COLUMN_NAME, UPDATABLE
FROM USER_UPDATABLE_COLUMNS
WHERE TABLE_NAME = 'EUROPEAN_MAKERS' ;

rem : Checking if Sample Row can be Inserted, not possible

INSERT INTO European_Makers VALUES(
'TATA','Nano 800','India');

rem : Checking if Sample Row can be Updated, yes on that cond that its not involved in foreign key relation

UPDATE European_Makers
SET Fullname = 'GGW'
WHERE Maker = 'bmw';

select * from european_makers;
select * from car_makers where maker = 'bmw';

rem : deletion, not possible due to presence of child records

delete from european_makers where maker = 'bmw';




rem : ***********************************************************
rem: 4) Create a view named Cars_Count which displays total number of cars
rem: manufactured by each country.

rem : NOTE: when using aggregate functions with views we need to provide alias for all coulumns selected

create or replace view cars_count(count_of_cars, country) as(
select count(cn.id), c.countryname
from model_details md
join car_makers cm
on md.makerid = cm.id
join countries c
on cm.countryid = c.countryid
join car_names cn
on cn.model = md.model
group by c.countryname);

select * from cars_count;

desc cars_count;

rem : Checking if View is updatable or not, none of the columns are updatable

SELECT COLUMN_NAME, UPDATABLE
FROM USER_UPDATABLE_COLUMNS
WHERE TABLE_NAME = 'CARS_COUNT';

rem : Checking if Sample Row can be Inserted, no

INSERT INTO Cars_Count VALUES(
'Morroco',23);

rem : Checking if Sample Row can be Updated, not legal on this view

UPDATE Cars_Count
SET count_of_cars = 900
WHERE COUNTRY = 'usa';

rem : Checking if Sample Row can be Deleted, not possible

DELETE FROM Cars_Count
WHERE COUNTRY = 'uk';

