
rem : to have access to the stdio in sql terminal
set serveroutput on;

rem: to ensure that sql does not consider the presence of blank lines as an error
set sqlblanklines on;

rem: this will show compilation errors in plsql procedures
-- show errors;

rem: 1. Check whether the given model is manufactured by any maker. If available, display the maker full name and country else display: “The given model is not manufactured / Invalid Model”

 DECLARE
    get_model car_names.model%TYPE;
     maker_name car_makers.fullname%TYPE;
     country countries.countryname%TYPE;
   BEGIN
     get_model := '&get_model';
     SELECT cm.fullname, co.countryname INTO maker_name, country
     FROM car_makers cm
     JOIN model_details md
     ON cm.id = md.makerid
     JOIN countries co
     ON co.Countryid = cm.countryid
     WHERE md.model = get_model;

     if not sql%found then 
	dbms_output.put_line(' no model found');
	return;
      end if;
   
     DBMS_OUTPUT.PUT_LINE('MODEL ' || get_model || ' IS MANUFACTURED');
     DBMS_OUTPUT.PUT_LINE('Maker Name: ' || maker_name);
     DBMS_OUTPUT.PUT_LINE('Country: ' || country);
  
  END;
   /


rem: 2. An user is desired to buy a car with the specific mileage. Ask the user for a mileage, and find the car that is equal or closest to the desired mileage. Print the car number, model, description and mileage. Also print the number of car(s) that is equal or closest to the given mileage.


DECLARE
    mileage NUMBER := &mileage;
    numberVal NUMBER := &numberVal;
    countVal NUMBER := 0;
BEGIN
    FOR car IN (
        SELECT cn.Id, cn.model, cn.makedescription, cd.mpg, ABS(cd.mpg - mileage) AS diff
        FROM CAR_NAMES cn JOIN CAR_DETAILS cd ON cn.Id = cd.Id
        ORDER BY diff
    )
    LOOP
        IF countVal != numberVal THEN
            DBMS_OUTPUT.PUT_LINE('CAR ID: ' || car.Id);
            DBMS_OUTPUT.PUT_LINE('MODEL: ' || car.model);
            DBMS_OUTPUT.PUT_LINE('CAR NAME: ' || car.makedescription);
            DBMS_OUTPUT.PUT_LINE('MILEAGE: ' || car.mpg);
            countVal := countVal + 1;
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE(countVal || ' car(s) found EQUAL/CLOSEST to given mileage');
END;
/

rem: 3. For a given country name, display the number of cars manufactured in each model by the car makers as shown below. Check for the availability of country name.

DECLARE
    input_country countries.countryname%TYPE := '&input_country';
    country_count NUMBER := 0;
    record_count NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO country_count
    FROM countries 
    WHERE countryname = input_country;  
    
    IF country_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('COUNTRY NOT IN DATABASE');
      RETURN;
    END IF;
  
    DBMS_OUTPUT.PUT_LINE('Country Name: ' || input_country);
    
  
    FOR rec IN (
	SELECT cm.maker, md.model, COUNT(*) AS num_cars
        FROM car_names cn
        JOIN car_details cd 
	ON cd.id = cn.id
        JOIN model_details md
	on md.model = cn.model
	JOIN car_makers cm
	on md.makerid = cm.id
	JOIN countries cou
	on cm.countryid = cou.countryid
	where cou.countryname = input_country
        GROUP BY cm.maker, md.model
	
    )
    LOOP
	IF record_count = 0 THEN
	  DBMS_OUTPUT.PUT_LINE('Maker Name' || ' ' || 'Model' || ' ' || 'No. of cars');
	END IF;
          DBMS_OUTPUT.PUT_LINE(rec.maker || ' ' || rec.model || ' ' || rec.num_cars);
	  record_count := record_count + rec.num_cars;

    END LOOP;
    
    IF record_count = 0 THEN
	DBMS_OUTPUT.PUT_LINE('The country ' || input_country || ' does not produce any car');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Total : ' || record_count);
END;
/



rem : using procedure for the same

create or replace procedure carsPerCountry(input_country IN countries.countryname%TYPE)
IS
isCountryThere int :=0;
cursor mycursor is 
	SELECT cm.maker, md.model, COUNT(*) AS num_cars
        FROM car_names cn
        JOIN car_details cd 
	ON cd.id = cn.id
        JOIN model_details md
	on md.model = cn.model
	JOIN car_makers cm
	on md.makerid = cm.id
	JOIN countries cou
	on cm.countryid = cou.countryid
	where cou.countryname = input_country
        GROUP BY cm.maker, md.model;

mycurIterator mycursor%ROWTYPE;
BEGIN

open mycursor;

/* error prone section
if mycursor%notfound then
	close mycursor;	
	return;
endif;
*/


dbms_output.put_line('maker'|| 'model'|| 'num_cars');


loop
fetch mycursor into mycurIterator;
dbms_output.put_line(mycurIterator.maker ||' '|| mycurIterator.model || '    ');
if mycursor%notfound then
	exit;
end if;
end loop;

close mycursor;

END;
/


rem: 1 way to execute
exec carsPerCountry('usa');

rem: 2nd way to execute

DECLARE
input_country countries.countryname%TYPE := NULL;
BEGIN

input_country := '&input_country';
carsPerCountry(input_country);

END;
/




rem : version2
create or replace procedure carsPerCountry(input_country IN countries.countryname%TYPE)
IS
isCountryThere int :=0;
cursor mycursor is 
	SELECT cm.maker, md.model, COUNT(*) AS num_cars
        FROM car_names cn
        JOIN car_details cd 
	ON cd.id = cn.id
        JOIN model_details md
	on md.model = cn.model
	JOIN car_makers cm
	on md.makerid = cm.id
	JOIN countries cou
	on cm.countryid = cou.countryid
	where cou.countryname = input_country
        GROUP BY cm.maker, md.model;
--mycurIterator mycursor%ROWTYPE;

v_maker mycursor.maker%TYPE;
v_model mycursor.model%TYPE;
v_num_cars mycursor.num_cars%TYPE;

BEGIN

if not mycursor%found then
	dbms_output.put_line('no data found');
	
end if;

open mycursor;

dbms_output.put_line('maker'|| 'model'|| 'num_cars');

loop
fetch mycursor into v_maker, v_model, v_num_cars;
if mycurIterator%notfound then
	exit;
end if;
dbms_output.put_line(v_maker || v_model || v_num_cars);
end loop;


close mycursor;


END;
/

rem:version3
create or replace procedure carsPerCountry(input_country IN countries.countryname%TYPE)
IS
isCountryThere int :=0;

BEGIN



dbms_output.put_line('maker'|| 'model'|| 'num_cars');

for i in (
	SELECT cm.maker, md.model, COUNT(*) AS num_cars
        FROM car_names cn
        JOIN car_details cd 
	ON cd.id = cn.id
        JOIN model_details md
	on md.model = cn.model
	JOIN car_makers cm
	on md.makerid = cm.id
	JOIN countries cou
	on cm.countryid = cou.countryid
	where cou.countryname = input_country
        GROUP BY cm.maker, md.model)
	
	loop
	dbms_output.put_line(i.maker|| i.model || i.num_cars);
	end loop;

END;
/






DECLARE
input_country countries.countryname%TYPE := NULL;
BEGIN
input_country := '&input_country';
carsPerCountry(input_country);
END;
/
	








