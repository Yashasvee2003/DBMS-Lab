/*
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

*/
rem : 1.Display the models that was not manufactured by any of the car makers.

SELECT Model
FROM MODEL_DETAILS md
WHERE Model NOT IN
(SELECT DISTINCT MODEL from CAR_NAMES);

rem : 2.For all the continents list the number of car makers if there were a car manufacturing company.

SELECT con.Continent,count(cm.ID) AS "Car Count"
FROM CONTINENTS con
LEFT JOIN COUNTRIES coun ON con.ContID = coun.ContID
LEFT JOIN CAR_MAKERS cm ON cm.CountryID = coun.CountryID
GROUP BY con.Continent;

rem : 3.Display the pair of cars (ID) that has same mileage, horsepower and acceleration. The pairs should not be repeated in the result.

SELECT DISTINCT cd1.ID,cd1.MPG,cd1.Horsepower,cd2.ID,cd2.MPG,cd2.Horsepower 
FROM CAR_DETAILS cd1 ,CAR_DETAILS cd2 
WHERE cd1.MPG = cd2.MPG AND cd1.Horsepower = cd2.Horsepower AND cd1.Accelerate = cd2.Accelerate AND cd1.ID < cd2.ID;

rem : 4.Display the number of cars produced by each car manufacturing company with in each model. Sort the result by the company name.

SELECT md.Model,cm.Maker,COUNT(*) AS "Car_Count"
FROM CAR_NAMES cn
JOIN MODEL_DETAILS md
ON ( md.Model = cn.Model)
JOIN CAR_MAKERS cm
ON cm.ID = md.MakerID
GROUP BY cm.Maker,md.Model
ORDER BY cm.Maker;


rem : 5. Display the model, name of car, mpg and weight of car(s) with maximum mileage among the heavy weight (bulky) cars. The car with weight more than the average weight of all cars are known as heavy weight (bulky) cars.


SELECT cn.Model,cn.MakeDescription,cd.MPG,cd.Weight
FROM CAR_NAMES cn
LEFT JOIN CAR_DETAILS cd
ON cn.ID = cd.ID 
WHERE cd.Weight > ( SELECT AVG(Weight) FROM CAR_DETAILS )
AND cd.MPG = ( SELECT MAX(MPG) FROM CAR_DETAILS 
WHERE Weight > ( SELECT AVG(Weight) FROM CAR_DETAILS)
);



rem : 6. Display the details (model,car_name,mileage,horsepower,acceleration,weight) of car(s) having mileage, horsepower, acceleration more than the average of mpg, horsepower, accel of all cars and its weight should be lesser than the average weight of all cars.



SELECT cn.Model,cn.MakeDescription,cd.MPG,cd.Horsepower,cd.accelerate,cd.Weight
FROM CAR_NAMES cn
LEFT JOIN CAR_DETAILS cd
ON cn.ID = cd.ID 
WHERE cd.MPG > ( SELECT AVG(MPG) FROM CAR_DETAILS)
AND cd.HorsePower > ( SELECT AVG(Horsepower) FROM CAR_DETAILS )
AND cd.Accelerate > ( SELECT AVG(Accelerate) FROM CAR_DETAILS )
AND cd.Weight < ( SELECT AVG(Weight) FROM CAR_DETAILS );



rem : 7. List the year, car maker that manufactured maximum number of cars.


SELECT cd.Year, cm.Maker, COUNT(*) AS "Car_Count"
FROM CAR_MAKERS cm
JOIN MODEL_DETAILS md ON cm.ID = md.MakerID
JOIN CAR_NAMES cn ON cn.Model = md.Model
JOIN CAR_DETAILS cd ON cn.ID = cd.ID
GROUP BY cd.Year, cm.Maker
HAVING COUNT(*) = (
  SELECT MAX(car_count)
  FROM (
    SELECT cd2.Year, cm2.Maker, COUNT(*) AS car_count
    FROM CAR_MAKERS cm2
    JOIN MODEL_DETAILS md2 ON cm2.ID = md2.MakerID
    JOIN CAR_NAMES cn2 ON cn2.Model = md2.Model
    JOIN CAR_DETAILS cd2 ON cn2.ID = cd2.ID
    GROUP BY cd2.Year, cm2.Maker
  ) subquery
  WHERE cd.Year = subquery.Year
  AND cm.Maker = subquery.Maker
)
ORDER BY COUNT(*) DESC
FETCH FIRST 1 ROW ONLY;




rem : 8. Display the maker name, model name, car name, mileage and year of the car with the maximum mileage for each model having more than one car. Sort the result by the car maker.

SELECT cm.Maker,md.Model,cn.MakeDescription,cd.MPG,cd.Year
FROM CAR_MAKERS cm
JOIN MODEL_DETAILS md ON cm.ID = md.MakerID
JOIN CAR_NAMES cn ON cn.Model = md.Model
JOIN CAR_DETAILS cd ON cn.ID = cd.ID
WHERE md.Model IN ( SELECT Model FROM CAR_NAMES GROUP BY Model HAVING COUNT(*) > 1)
AND cd.MPG =( SELECT MAX(MPG) FROM CAR_DETAILS cd2 join CAR_NAMES cn2 on cd2.id = cn2.id where cn2.Model = cn.Model)
ORDER BY cm.maker;


rem : 9. Rewrite the query 1.


SELECT Model
FROM MODEL_DETAILS
MINUS
SELECT Model
FROM CAR_Names;


rem : 10. List the car names (description) and its details that was manufactured on 1976 and 1982.

SELECT cn.Makedescription, cd.MPG, cd.Cylinders, cd.Edispl, cd.Horsepower, cd.Weight, cd.Accelerate, cd.Year
FROM CAR_NAMES cn 
JOIN CAR_DETAILS cd
ON cd.ID = cn.ID
WHERE year = 1976
UNION
SELECT cn.Makedescription, cd.MPG, cd.Cylinders, cd.Edispl, cd.Horsepower, cd.Weight, cd.Accelerate, cd.Year
FROM CAR_NAMES cn 
JOIN CAR_DETAILS cd
ON cd.ID = cn.ID
WHERE year = 1982
INTERSECT
SELECT cn.Makedescription, cd.MPG, cd.Cylinders, cd.Edispl, cd.Horsepower, cd.Weight, cd.Accelerate, cd.Year
FROM CAR_NAMES cn 
JOIN CAR_DETAILS cd
ON cd.ID = cn.ID;
