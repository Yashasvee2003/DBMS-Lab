drop table transaction;
drop table accounts;
drop table customers;

create table customers(
cid number(10) constraint cust_pk primary key,
cname varchar2(30),
age number(10),
address varchar2(30),
phone number(20)
);

create table accounts(
ano varchar2(10) constraint acc_pk primary key,
atype varchar2(2),
balance number(10),
cid number(10) constraint acc_fk references customers(cid)
);


create table transaction(
tid number(10) constraint tran_pk primary key,
ano varchar2(10) constraint trans_fk references accounts(ano),
ttype varchar2(10),
tdate date,
tamount number(10)
);




REM --------------------------------------------------------------------------
REM CUSTOMERS
REM ---------------
REM CID, CNAME, AGE, ADDRESS, PHONE

INSERT INTO CUSTOMERS VALUES(100,'Adithya',25,'Anna nagar, Chennai',9843748255);
INSERT INTO CUSTOMERS VALUES(101,'Nikhil Arora',28,'Mogapair West, Chennai',9345672438);
INSERT INTO CUSTOMERS VALUES(102,'Aradhana',31,'East Tambaram, Chennai',9523495687);
INSERT INTO CUSTOMERS VALUES(103,'Raghav',34,'Nanganallur, Chennai',9441245636);


REM ACCOUNTS
REM ---------------
REM ANO, ATYPE, BALANCE, CID

INSERT INTO ACCOUNTS VALUES('S103','S',1500,100);
INSERT INTO ACCOUNTS VALUES('C121','C',5000,100);
INSERT INTO ACCOUNTS VALUES('S201','S',45000,101);
INSERT INTO ACCOUNTS VALUES('S223','S',7200,102);
INSERT INTO ACCOUNTS VALUES('C135','C',245000,103);


REM TRANSACTION
REM ---------------
REM TID, ANO, TTYPE, TDATE, TAMOUNT

 