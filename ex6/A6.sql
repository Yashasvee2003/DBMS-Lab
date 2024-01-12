
Rem 1. Engine capacity or engine displacement is the engine power which is measured in cubic inches or cc (cubic centimeter) or liters. Small cars are measured using cc (up to 2000 cc). Liters are used for large cars. Using the above metric, display the engine capacity in cc or liters and categorize into small or large car respectively for the given car id. 

CREATE OR REPLACE PROCEDURE display_engine_capacity(
  p_car_id IN CAR_DETAILS.Id%TYPE
) IS
  v_engine_capacity_cc NUMBER;
  v_engine_capacity_liters NUMBER;
  v_car_type VARCHAR2(10);
BEGIN

  SELECT edispl
  INTO v_engine_capacity_cc
  FROM CAR_DETAILS
  WHERE Id = p_car_id;

  v_engine_capacity_liters := v_engine_capacity_cc * 0.0164;

  IF v_engine_capacity_cc <= 2000 THEN
    v_car_type := 'Small';
  ELSE
    v_car_type := 'Large';
  END IF;

  DBMS_OUTPUT.PUT_LINE('Engine Capacity: ' || v_engine_capacity_cc || ' cc (' || v_engine_capacity_liters || ' liters)');
  DBMS_OUTPUT.PUT_LINE('Car Type: ' || v_car_type);
END;
/

DECLARE
Id CAR_DETAILS.Id%TYPE := &Id;
BEGIN 
display_engine_capacity(Id);
END;
/

Rem 2. Taking a road trip can be the ideal way to see the countryside. You have planned for a trip to a holiday spot on weekend. Select the best car among the given model to reach the spot. The best car is determined by the lowest fuel consumption cost to the trip. Input the distance (miles) to reach the spot and fuel cost ($ / gallons of gas). Fuel consumption cost = (miles / mpg) x fuel cost. 

CREATE OR REPLACE PROCEDURE recommend_best_car(
  p_distance IN NUMBER,
  p_fuel_cost IN NUMBER,
  p_model_name IN CAR_NAMES.Model%TYPE
) IS
  v_lowest_cost NUMBER := NULL;
  v_best_car_id CAR_DETAILS.Id%TYPE := NULL;
  v_fuel_consumption_cost NUMBER;
BEGIN
  FOR car_rec IN (SELECT c.Id, cn.model, c.mpg
                  FROM CAR_DETAILS c, CAR_NAMES cn 
		   WHERE cn.Id = c.Id AND cn.Model =   p_model_name ) LOOP
    v_fuel_consumption_cost := (p_distance / car_rec.mpg) * p_fuel_cost;

    IF v_lowest_cost IS NULL OR v_fuel_consumption_cost < v_lowest_cost THEN
      v_lowest_cost := v_fuel_consumption_cost;
      v_best_car_id := car_rec.Id;
    END IF;

   END LOOP;

  IF v_best_car_id IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('Best Car ID: ' || v_best_car_id || ' is the best car for the trip!');
  ELSE
    DBMS_OUTPUT.PUT_LINE('No cars available for recommendation.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;
/

DECLARE 
distance NUMBER := &distance;
cost NUMBER := &cost;
model_name CAR_NAMES.Model%TYPE := '&model_name';
BEGIN 
recommend_best_car(distance, cost, model_name);
END;
/


Rem  3. The power-to-weight ratio formula for an engine is the power (hp) generated by the engine divided by the weight (lbs). This is commonly applied to engines and is used as a measurement of performance of a vehicle as whole. Display the car name that has highest, lowest power-to-weight ratio. 

CREATE OR REPLACE PROCEDURE display_power_to_weight_ratio IS
  v_highest_ratio NUMBER;
  v_lowest_ratio NUMBER;
  v_highest_car CAR_NAMES.model%TYPE;
  v_lowest_car CAR_NAMES.model%TYPE;

BEGIN

  SELECT (cd.horsepower /cd.weight) AS ratio, cn.model
  INTO v_highest_ratio, v_highest_car
  FROM CAR_DETAILS cd, CAR_NAMES cn
  WHERE cd.Id = cn.Id AND
   (cd.horsepower /cd.weight)  = (SELECT MAX(cd.horsepower /cd.weight) FROM CAR_DETAILS cd, CAR_NAMES cn );

  SELECT (cd.horsepower /cd.weight) AS ratio, cn.model
  INTO v_lowest_ratio, v_lowest_car
  FROM CAR_DETAILS cd, CAR_NAMES cn
  WHERE cd.Id = cn.Id AND
   (cd.horsepower /cd.weight)  = (SELECT MIN(cd.horsepower /cd.weight) FROM CAR_DETAILS cd, CAR_NAMES cn );

  DBMS_OUTPUT.PUT_LINE('Car with Highest Power-to-Weight Ratio: ' || v_highest_car || ' with ratio : ' || round(v_highest_ratio, 2));
  DBMS_OUTPUT.PUT_LINE('Car with Lowest Power-to-Weight Ratio: ' || v_lowest_car || ' with ratio : ' || round(v_lowest_ratio, 2));
END;
/

BEGIN 
display_power_to_weight_ratio;
END;
/


Rem 4. Develop a stored function which returns the car that exactly or nearly matches the given mpg and acceleration of the car. If no car matches, then return the car that matches either mpg or acceleration. 
rem : give 18, 12 as input

CREATE OR REPLACE FUNCTION find_matching_car(
  p_mpg IN CAR_DETAILS.mpg%TYPE,
  p_accel IN CAR_DETAILS.accelerate%TYPE
) RETURN CAR_DETAILS.Id%TYPE 
IS
  v_car_id CAR_DETAILS.Id%TYPE := NULL;
BEGIN

  SELECT Id
  INTO v_car_id
  FROM CAR_DETAILS
  WHERE mpg = p_mpg AND accelerate = p_accel;

  IF v_car_id IS NULL THEN
    SELECT Id
    INTO v_car_id
    FROM CAR_DETAILS
    WHERE mpg = p_mpg OR accelerate = p_accel;
  END IF;

  RETURN v_car_id;
END;
/

DECLARE 
Id CAR_DETAILS.Id%TYPE;
mpg CAR_DETAILS.mpg%TYPE := &mpg;
accel CAR_DETAILS.accelerate%TYPE := &accel;
BEGIN 
Id := find_matching_car(mpg, accel);
dbms_output.put_line(' Car Id : ' || Id);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(' No data found ');
END;
/

Rem 5. Consider the problem 2. Rewrite it into stored function that returns the car ID which consumes minimum fuel cost. 

CREATE OR REPLACE FUNCTION find_best_car(
  p_distance IN NUMBER,
  p_fuel_cost IN NUMBER,
  p_model_name IN CAR_NAMES.Model%TYPE
) RETURN CAR_DETAILS.Id%TYPE
IS
  min_fuel_cost_Id CAR_DETAILS.Id%TYPE := NULL;
  v_lowest_cost NUMBER := NULL;
  v_best_car_id CAR_DETAILS.Id%TYPE := NULL;
  v_fuel_consumption_cost NUMBER;
BEGIN
  FOR car_rec IN (SELECT c.Id, cn.model, c.mpg
                  FROM CAR_DETAILS c, CAR_NAMES cn
                  WHERE cn.Id = c.Id AND cn.Model = p_model_name) LOOP
    v_fuel_consumption_cost := (p_distance / car_rec.mpg) * p_fuel_cost;

    IF v_lowest_cost IS NULL OR v_fuel_consumption_cost < v_lowest_cost THEN
      v_lowest_cost := v_fuel_consumption_cost;
      v_best_car_id := car_rec.Id;
    END IF;

  END LOOP;

  min_fuel_cost_Id := v_best_car_id;
  RETURN min_fuel_cost_Id;
END;
/

DECLARE 
Id CAR_DETAILS.Id%TYPE;
distance NUMBER := &distance;
cost NUMBER := &cost;
model_name CAR_NAMES.Model%TYPE := '&model_name';
BEGIN 
Id := find_best_car(distance, cost, model_name);
dbms_output.put_line(' Best car Id returned by the function : ' || Id);
END;
/




