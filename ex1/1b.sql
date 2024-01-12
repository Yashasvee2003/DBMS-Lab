REM : execute this after executing a.sql
REM: ********************************************************************************


REM : It is identified that the number of children have to be mentioned while booking the boat by the tourists.
ALTER TABLE reservation ADD(child_no INT);
desc reservation;


REM : The width of a tourist name is not adequate for most of the tourists.
ALTER TABLE tourists MODIFY( tourist_name varchar2(100));
desc tourists;

REM : Reservation can not be done without the reserve_date.
ALTER TABLE reservation MODIFY( do_reserve NOT NULL);
desc reservation;
INSERT INTO Reservation VALUES ('b001', 's002', 't002', 30, NULL, TO_DATE('2023-03-20', 'YYYY-MM-DD') ,12);


REM : The date•of•birth of a tourist can be addressed later. hence dropping it
ALTER TABLE tourists DROP COLUMN tourist_dob;
desc tourists;

REM : The rating for sailor – D has to be added.
ALTER TABLE sailors MODIFY(CONSTRAINT rating_category CHECK(SAILOR_RATING IN ('A', 'B','C', 'D')));
INSERT INTO Sailors VALUES ('s005', 'Stuart ELLL', 'D', TO_DATE('1985-02-12', 'YYYY-MM-DD'));

REM : All luxurious boats are colored yellow.
REM : version 2 ********************
delete from Reservation;
delete from Boats;
alter table boats drop constraint chk_type;

ALTER TABLE Boats ADD CONSTRAINT valid_colour CHECK((color like 'yellow' and boat_type in ('LUX')) or boat_type in ('CAR', 'CRU'));

rem : Inserting Valid Rows

INSERT INTO Boats Values('B106','Phantom','LUX',1234,7500,'yellow');
INSERT INTO Boats Values('B107','Vandal','LUX',123,6400,'yellow');

rem : Inserting Invalid Rows

INSERT INTO Boats Values('B108','Frenzy','LUX',5376,6400,'Black');



rem : Restoring Values 


ALTER TABLE reservation DROP COLUMN CHILD_NO;


INSERT INTO Boats VALUES ('b001', 'ABBA', 'LUX', 150, 2000.00, 'yellow');
INSERT INTO Boats VALUES ('b002', 'OTPQ', 'CAR', 120, 1200.00, 'red');

INSERT INTO Reservation VALUES ('b001', 's001', 't001', 30, TO_DATE('2023-03-20', 'YYYY-MM-DD'), TO_DATE('2023-03-25', 'YYYY-MM-DD'));
INSERT INTO Reservation VALUES ('b002', 's001', 't002', 30, TO_DATE('2023-03-20', 'YYYY-MM-DD'), TO_DATE('2023-03-25', 'YYYY-MM-DD'));
INSERT INTO Reservation VALUES ('b001', 's002', 't002', 30, TO_DATE('2023-03-20', 'YYYY-MM-DD'), TO_DATE('2023-03-25', 'YYYY-MM-DD'));


REM : Each boat should have different name.
ALTER TABLE boats MODIFY( CONSTRAINT boat_name_unique boat_name UNIQUE);

REM: entering faulty value
INSERT INTO Boats VALUES ('b0011', 'ABBA', 'CAR', 150, 2000.00, 'magenta');

REM : A sailor may resign his job later or a boat may get damaged. Hence on removing the
details of the sailor / boat, ensure that all the corresponding details are also deleted.

alter table reservation drop constraint boat_fk;
alter table reservation drop constraint sailor_fk;
alter table reservation modify( constraint boat_fk foreign key (boat_id) references boats(boat_id) on delete cascade );
alter table reservation modify( constraint sailor_fk foreign key (sailor_id) references sailors(sailor_id) on delete cascade );
select * from boats;
select * from reservation;
delete from boats where boat_id = 'b001';
select * from boats;
select * from reservation;