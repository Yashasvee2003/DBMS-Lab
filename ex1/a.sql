REM: dropping the tables 

drop table Reservation;
drop table Tourists;
drop table Sailors;
drop table Boats;
commit;


REM: creating table boats
CREATE TABLE Boats (
  boat_id varchar2(10) CONSTRAINT pk_boat PRIMARY KEY,
  boat_name VARCHAR2(50),
  boat_type VARCHAR2(3) CONSTRAINT chk_type CHECK (boat_type IN ('LUX', 'CAR', 'CRU')),
  max_capacity NUMBER(5) ,
  price_per_seat NUMBER(10,2),
  color VARCHAR2(20)
);

desc boats;

INSERT INTO Boats VALUES ('b001', 'ABBA', 'LUX', 150, 2000.00, 'magenta');
INSERT INTO Boats VALUES ('b002', 'OTPQ', 'CAR', 120, 1200.00, 'red');
REM: primary key violation
INSERT INTO Boats VALUES ('b001', 'OTPQ', 'CAR', 120, 1200.00, 'red');
REM : type violation
INSERT INTO Boats VALUES ('b003', 'ALTR', 'CAB', 130, 1200.00, 'orange');
INSERT INTO Boats VALUES ('b003', 'ALTR', 'CAB', NULL, 1200.00, 'orange');

select * from Boats;

REM : creating table sailors
CREATE TABLE Sailors (
  sailor_id varchar2(5) CONSTRAINT sailorid_pk PRIMARY KEY,
  sailor_name VARCHAR2(50),
  sailor_rating VARCHAR2(1) CONSTRAINT rating_check CHECK(sailor_rating IN ('A', 'B', 'C')),
  sailor_DOB DATE CONSTRAINT age_check CHECK (2023 - extract(year from sailor_DOB) >= 25)
);

desc Sailors;

INSERT INTO Sailors VALUES ('s001', 'Jack Rosenthal', 'A', TO_DATE('1990-06-20', 'YYYY-MM-DD'));
INSERT INTO Sailors VALUES ('s002', 'Stuart Green', 'A', TO_DATE('1985-02-12', 'YYYY-MM-DD'));

REM : primary key violation
INSERT INTO Sailors VALUES ('s001', 'Carol Bloom', 'B', TO_DATE('1945-02-23', 'YYYY-MM-DD'));

REM : invalid rating for sailor
INSERT INTO Sailors VALUES ('s003', 'Virat Kohli', 'D', TO_DATE('1985-11-18', 'YYYY-MM-DD'));

REM : invalid age for sailor
INSERT INTO Sailors VALUES ('s003', 'Virat Kohli', 'B', TO_DATE('2003-11-18', 'YYYY-MM-DD'));

select * from Sailors;


REM : creating table tourists
CREATE TABLE Tourists (
  tourist_no varchar2(5) CONSTRAINT tourist_pk PRIMARY KEY,
  tourist_name VARCHAR2(50),
  address VARCHAR2(100),
  tourist_DOB DATE,
  phone VARCHAR2(20)
);

desc Tourists;

INSERT INTO Tourists VALUES ('t001', 'MS Dhoni', '5th Ave, CA', TO_DATE('1995-04-12', 'YYYY-MM-DD'), '91-1238947681');
INSERT INTO Tourists VALUES ('t002', 'R Ashwin', '12th Ave, CA', TO_DATE('1985-12-15', 'YYYY-MM-DD'), '91-9364027814');

REM : primary key violation
INSERT INTO Tourists VALUES ('t001', 'MS Dhoni', '5th Ave, CA', TO_DATE('1995-04-12', 'YYYY-MM-DD'), '91-1238947681');

select * from Tourists;

REM : creating table reservation
CREATE TABLE Reservation (
  boat_id varchar2(5),
  sailor_id varchar2(5),
  tourist_no varchar2(5),
  no_sail NUMBER(5),
  DO_reserve DATE,
  DO_sail DATE,
  CONSTRAINT reserve_pk PRIMARY KEY (boat_id, sailor_id, DO_sail),
  CONSTRAINT boat_fk FOREIGN KEY (boat_id) REFERENCES Boats(boat_id),
  CONSTRAINT sailor_fk FOREIGN KEY (sailor_id) REFERENCES Sailors(sailor_id),
  CONSTRAINT tourist_fk FOREIGN KEY (tourist_no) REFERENCES Tourists(tourist_no),
  CONSTRAINT DOreserve_check CHECK (DO_reserve < DO_sail),
  CONSTRAINT advance_check CHECK (DO_sail - DO_reserve <= 12)
);

desc Reservation;

INSERT INTO Reservation VALUES ('b001', 's001', 't001', 30, TO_DATE('2023-03-20', 'YYYY-MM-DD'), TO_DATE('2023-03-25', 'YYYY-MM-DD'));

REM : 2 tourists cannot book the same boat, sailor on the same date
INSERT INTO Reservation VALUES ('b001', 's001', 't002', 30, TO_DATE('2023-03-20', 'YYYY-MM-DD'), TO_DATE('2023-03-25', 'YYYY-MM-DD'));
INSERT INTO Reservation VALUES ('b002', 's001', 't002', 30, TO_DATE('2023-03-20', 'YYYY-MM-DD'), TO_DATE('2023-03-25', 'YYYY-MM-DD'));
INSERT INTO Reservation VALUES ('b001', 's002', 't002', 30, TO_DATE('2023-03-20', 'YYYY-MM-DD'), TO_DATE('2023-03-25', 'YYYY-MM-DD'));

REM : can only book a maximum of 12 days in advance
INSERT INTO Reservation VALUES ('b002', 's002', 't002', 30, TO_DATE('2023-03-07', 'YYYY-MM-DD'), TO_DATE('2023-03-25', 'YYYY-MM-DD'));

REM : reserving after sail dates
INSERT INTO Reservation VALUES ('b002', 's002', 't002', 30, TO_DATE('2023-04-26', 'YYYY-MM-DD'), TO_DATE('2023-03-25', 'YYYY-MM-DD'));

select * from Reservation;
