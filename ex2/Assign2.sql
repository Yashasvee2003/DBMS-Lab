rem: drop the preexisting tables
DROP TABLE Sailor;


rem : creating sailor table
CREATE TABLE Sailor( SailorID VARCHAR2(10) CONSTRAINT sailor_pk PRIMARY KEY, Name VARCHAR2(20), Rating VARCHAR2(2), DOB date, Salary INT);


rem: inserting tuples into sailor table
INSERT INTO Sailor (SailorID, Name, Rating, DOB, Salary) 
VALUES ('S100', 'Raman', 'A', TO_DATE('01-OCT-1980', 'DD-MON-YYYY'), 27000);

INSERT INTO Sailor (SailorID, Name, Rating, DOB, Salary) 
VALUES ('S200', 'Krishna', 'B', TO_DATE('04-JUL-1978', 'DD-MON-YYYY'), 21000);

INSERT INTO Sailor (SailorID, Name, Rating, DOB, Salary) 
VALUES ('S300', 'Gokul', 'C', TO_DATE('05-FEB-1975', 'DD-MON-YYYY'), 16000);

INSERT INTO Sailor (SailorID, Name, Rating, DOB, Salary) 
VALUES ('S400', 'Ravi', 'D', TO_DATE('06-APR-1984', 'DD-MON-YYYY'), 10000);

INSERT INTO Sailor (SailorID, Name, Rating, DOB, Salary) 
VALUES ('S500', 'James', 'A', TO_DATE('07-MAR-1983', 'DD-MON-YYYY'), 25000);

INSERT INTO Sailor (SailorID, Name, Rating, DOB, Salary) 
VALUES ('S600', 'Vasanth', 'B', TO_DATE('20-MAR-1985', 'DD-MON-YYYY'), 20600);

INSERT INTO Sailor (SailorID, Name, Rating, DOB, Salary) 
VALUES ('S700', 'Rahul', 'C', TO_DATE('13-DEC-1985', 'DD-MON-YYYY'), 15500);

INSERT INTO Sailor (SailorID, Name, Rating, DOB, Salary) 
VALUES ('S800', 'Vijay', null, TO_DATE('13-DEC-1990', 'DD-MON-YYYY'), 5000);



rem : Display the name and salary of sailors earning more than $10000
SELECT Name, Salary 
FROM Sailor 
WHERE Salary > 10000;


rem : Display the unique ratings of sailor from the SAILOR relation.
rem : we can also use distinct 
SELECT UNIQUE Rating 
FROM Sailor;


rem : Display sailor name, hike salary by 10% and label the columns as Sailor Name and New Salary respectively
rem : alias should be in quotes
SELECT Name AS "Sailor Name", Salary * 1.1 AS "New Salary" 
FROM Sailor;

rem : List sailor id, name, salary of all sailor(s) who was not rated yet
rem : we cannot use = operator while comparing for NULL
SELECT SailorID, Name, Salary 
FROM Sailor 
WHERE Rating IS NULL;



rem : Show all data for sailors whose name starts with R and born before the year 1985
rem : we can also create a date using TO_DATE() and compare dob with this
SELECT * 
FROM Sailor 
WHERE Name LIKE 'R%' AND extract(year from DOB) < 1985;


rem : Display name, rating, salary of all sailors whose rating is A or B and whose salary is not equal to $21000 rem : and $25000.
SELECT Name, Rating, Salary 
FROM Sailor 
WHERE (Rating IN ('A', 'B')) AND Salary NOT IN (21000, 25000);


rem : Modify the query in 2 to display the name and salary of all sailors whose salary is not in the range of
rem : $10000 to $16000 *****
SELECT Name, Salary 
FROM Sailor 
WHERE Salary NOT BETWEEN 10000 AND 16000;

rem : List the sailors who was born between Jan 1985 and Dec 1985
SELECT * 
FROM Sailor 
WHERE DOB BETWEEN TO_DATE('01-JAN-1985', 'DD-MON-YYYY') AND TO_DATE('31-DEC-1985', 'DD-MON-YYYY');

rem : Show the name of sailors together with their age in number of years and months.
rem : [E.g., 18 Yrs 4 Months].
rem : using || to concatenate columns
SELECT Name, 
TRUNC(MONTHS_BETWEEN(SYSDATE, DOB) / 12) || ' Yrs ' || 
MOD(TRUNC(MONTHS_BETWEEN(SYSDATE, DOB)), 12) || ' Months' AS "Age"
FROM Sailor;


rem : Display the sailor id and name of a sailor whose name has second letter a. Sort the result
rem : by name in descending order
SELECT SailorID, Name
FROM Sailor
WHERE Name LIKE '_a%'
ORDER BY Name DESC;


rem : Show those sailors whose name starts with J,K, or R.
SELECT *
FROM Sailor
WHERE Name LIKE 'J%' OR Name LIKE 'K%' OR Name LIKE 'R%';


rem : How many sailors have a name that ends with letter l
rem : we can also use where name like '%l'
SELECT COUNT(*)
FROM Sailor
WHERE SUBSTR(Name, -1) = 'l';


rem : Display highest, lowest, sum and average salary earned by the sailors in ratingwise. Label
rem : the columns as Max, Min, Sum, and Avg respectively. Round your results to the nearest
rem : whole number. Sort your result by alphabetical order of rating
SELECT rating,
       ROUND(MAX(Salary)) AS "Max",
       ROUND(MIN(Salary)) AS "Min",
       ROUND(SUM(Salary)) AS "Sum",
       ROUND(AVG(Salary)) AS "Avg"
FROM Sailor
GROUP BY rating
ORDER BY rating;


rem : . Display the total salary for each rating. Exclude the ratings where the total salary is less
rem : than $25000
SELECT rating, SUM(Salary) AS "Total Salary"
FROM Sailor
GROUP BY rating
HAVING SUM(Salary) > 25000;

rem : . Display the rating and salary of the lowest paid sailor in each rating. Exclude anyone whose
rem : rating is not known. Exclude any groups where the minimum salary is $15000 or less. Sort
rem : the output in descending order of salary.
rem : we can also put rating is not null as a where clause before grouping
SELECT Rating, MIN(Salary) as "Min Salary"
FROM sailor
GROUP BY Rating
HAVING SUM(Salary) > 15000 AND rating IS NOT NULL
ORDER BY "Min Salary" desc;


rem : alternate way
SELECT Rating, MIN(Salary) Mino
FROM sailor
GROUP BY Rating
HAVING SUM(Salary) > 15000 AND rating IS NOT NULL
ORDER BY Mino desc;



rem :******** USING UPDATE , DELETE , TCL COMMANDS*********
rem :  Mark an intermediate point in the transaction (savepoint)
savepoint sp1;


rem :  Update the rating, salary of S800 to A, 10000 respectively.
SELECT * FROM SAILOR;

UPDATE Sailor
SET rating = 'A', Salary = 10000
WHERE SailorID = 'S800';

SELECT * FROM SAILOR;


rem : Mark an intermediate point in the transaction (savepoint)
savepoint sp2;

rem : Update the salary of all sailors with a hike by 5%
UPDATE Sailor
SET Salary = Salary * 1.05;

rem : Delete the sailor(s) who was born before 1985.
DELETE FROM Sailor
WHERE DOB < '01-JAN-1985';

rem : Display the sailor relation
SELECT *
FROM Sailor;

rem : Discard the most recent update operations (rollback)
rollback to savepoint sp2;
SELECT * 
FROM Sailor;

rem : Commit the change
commit;


