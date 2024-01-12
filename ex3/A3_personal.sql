rem : Dropping Tables

DROP TABLE Car_Details;
DROP TABLE Car_Names;
DROP TABLE Model_Details;
DROP TABLE Car_Makers;
DROP TABLE Countries;
DROP TABLE Continents;



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

@ "C:\Users\vipur\ssn\sem 4\lab\DBMS\ex3\cars_new.sql";

rem : 1.Display the models that was not manufactured by any of the car makers.

/*
select md.model
from model_details md
left outer join car_names cn
on cn.model = md.model
where cn.model is NULL;
*/

rem : this method is preffered
SELECT Model
FROM MODEL_DETAILS md
WHERE Model NOT IN
(SELECT DISTINCT MODEL from CAR_NAMES);


rem : 2.For all the continents list the number of car makers if there were a car manufacturing company.

select con.continent, count(cm.maker)
from continents con
join countries coun 
on con.contid = coun.contid
join car_makers cm
on coun.countryid = cm.countryid
group by con.continent;

rem : 3.Display the pair of cars (ID) that has same mileage, horsepower and acceleration. The pairs should not be repeated in the result.

select cd1.ID,cd1.MPG,cd1.Horsepower,cd2.ID,cd2.MPG,cd2.Horsepower
from car_details cd1
join car_details cd2 
on cd1.id != cd2.id AND cd1.MPG = cd2.MPG AND cd1.Horsepower = cd2.Horsepower AND cd1.Accelerate = cd2.Accelerate AND cd1.id < cd2.id ;

rem : 4.Display the number of cars produced by each car manufacturing company with in each model. Sort the result by the company name.

select cm.maker,cn.model, count(cn.model)
from car_makers cm
join model_details md 
on cm.id = md.makerid
join car_names cn 
on cn.model = md.model
group by cm.maker, cn.model
order by cm.maker ;



rem : 5. Display the model, name of car, mpg and weight of car(s) with maximum mileage among the heavy weight (bulky) cars. The car with weight more than the average weight of all cars are known as heavy weight (bulky) cars.


rem : using joins
select cn.model, cn.makedescription, cd.mpg, cd.weight
from car_names cn
join car_details cd
on cn.id = cd.id
where cd.weight >= (select avg(weight) from car_details) AND cd.mpg is NOT NULL
order by cd.mpg desc
fetch first 1 rows only;



rem : using more nested subqueries (preffered)
/*
SELECT cn.Model,cn.MakeDescription,cd.MPG,cd.Weight
FROM CAR_NAMES cn
LEFT JOIN CAR_DETAILS cd
ON cn.ID = cd.ID 
WHERE cd.Weight > ( SELECT AVG(Weight) FROM CAR_DETAILS )
AND cd.MPG = ( SELECT MAX(MPG) FROM CAR_DETAILS 
WHERE Weight > ( SELECT AVG(Weight) FROM CAR_DETAILS)
);
*/


rem : 6. Display the details (model,car_name,mileage,horsepower,acceleration,weight) of car(s) having mileage, horsepower, acceleration more than the average of mpg, horsepower, accel of all cars and its weight should be lesser than the average weight of all cars.



select cn.Model,cn.MakeDescription,cd.MPG,cd.Horsepower,cd.accelerate,cd.Weight
from car_names cn
join car_details cd
on cn.id = cd.id
where
	cd.mpg > (select avg(mpg) from car_details) AND
	cd.horsepower > (select avg(horsepower) from car_details) AND
	cd.accelerate > (select avg(accelerate) from car_details) AND
	cd.weight < (select avg(weight) from car_details)
;
	

rem : 7. List the year, car maker that manufactured maximum number of cars.

	
select cd.Year, cm.Maker, COUNT(cd.id) AS "car_count"
FROM CAR_MAKERS cm
JOIN MODEL_DETAILS md ON cm.ID = md.MakerID
JOIN CAR_NAMES cn ON cn.Model = md.Model
JOIN CAR_DETAILS cd ON cn.ID = cd.ID
group by cm.maker, cd.year
order by "car_count" desc
fetch first 1 row only;

rem : 8. Display the maker name, model name, car name, mileage and year of the car with the maximum mileage for each model having more than one car. Sort the result by the car maker.
rem: *************IMP************
SELECT cm.Maker,md.Model,cn.MakeDescription,cd.MPG,cd.Year
FROM CAR_MAKERS cm
JOIN MODEL_DETAILS md ON cm.ID = md.MakerID
JOIN CAR_NAMES cn ON cn.Model = md.Model
JOIN CAR_DETAILS cd ON cn.ID = cd.ID
where md.model in ( select model from car_names group by model having count(*) > 1)
AND cd.mpg = (select max(mpg) from car_details cd2
			join car_names cn2
			on cn2.id = cd2.id
			AND cn2.model = cn.model)
;


rem : 9. Rewrite the query 1.

SELECT Model
FROM MODEL_DETAILS
intersect
SELECT Model
FROM CAR_Names;

rem : 10. List the car names (description) and its details that was manufactured on 1976 and 1982.

SELECT cn.Makedescription, cd.MPG, cd.Cylinders, cd.Edispl, cd.Horsepower, cd.Weight, cd.Accelerate, cd.year
FROM CAR_NAMES cn 
JOIN CAR_DETAILS cd
ON cd.ID = cn.ID
WHERE year = 1976
UNION
SELECT cn.Makedescription, cd.MPG, cd.Cylinders, cd.Edispl, cd.Horsepower, cd.Weight, cd.Accelerate, cd.year
FROM CAR_NAMES cn 
JOIN CAR_DETAILS cd
ON cd.ID = cn.ID
WHERE year = 1982;
