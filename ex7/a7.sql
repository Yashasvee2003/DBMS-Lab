rem: ------------------------------------------------------------------------------------>
rem: Qeustion-1 During Withdrawal, check whether the transaction amount is less than the available balance. Event : Insert/Update (tamount)
rem: If ttype=Withdrawal and tamount>balance then
rem: raise 'Available Balance is lesser than the Transaction amount'


CREATE OR REPLACE TRIGGER min_bal
BEFORE INSERT OR UPDATE of tamount ON transaction
FOR EACH ROW
DECLARE
    bal accounts.balance%TYPE;
BEGIN
    SELECT balance INTO bal FROM accounts WHERE ano = :new.ANO;
    IF :new.TTYPE = 'W' AND bal < :new.TAMOUNT THEN
        RAISE_APPLICATION_ERROR(-20001, 'Available Balance is lesser than the Transaction amount');
    END IF;
END;
/

rem : trying to withdraw more then the remaining balance, raises error
insert into transaction values(1,'C121','W','19-Jan-2023',10000);


rem :------------------------------------------------------------------------------------------------------------->

rem: Implement the following constraint to update the balance of an account for the transactions of both the Deposit or Withdrawal type.
rem: Event : Insert/Update (tamount)
rem: If ttype = Deposit then balance = balance + tamount If ttype = Withdrawal then balance = balance - tamount



CREATE OR REPLACE TRIGGER update_balance
BEFORE INSERT OR UPDATE OF tamount, ttype ON transaction
FOR EACH ROW
BEGIN
   IF :new.ttype = 'Deposit' THEN

      UPDATE accounts SET balance = balance + :new.tamount WHERE ano = :new.ano;
     

   ELSIF :new.ttype = 'Withdrawal' THEN
      UPDATE accounts SET balance = balance - :new.tamount WHERE ano = :new.ano;
      
   END IF;
END;
/

rem : depositing an amount of 5000 into account S201
insert into transaction values(1,'S201','Deposit','19-Jan-2023',5000);
select * from accounts where ano='S201';

rem: ----------------------------------------------------------------------------->
rem: query-3 Implement the following constraint for Withdrawal transactions. 
rem: Event : Insert
rem: a. A customer can have at most 3 withdrawals per day per account.
rem: b. The maximum amount of withdrawal for each transaction is Rs.30000

CREATE OR REPLACE TRIGGER trig_warn
BEFORE INSERT ON transaction
FOR EACH ROW
DECLARE
  num NUMBER(10);
  daily_withdrawal_count NUMBER(10);
  temp transaction%rowtype ;
  cursor c1 is SELECT *
  FROM transaction
  WHERE ano = :new.ano AND tdate = :new.tdate AND ttype = 'W';
BEGIN
  -- Check if the transaction type is 'W' for withdrawal
  IF :new.ttype = 'W' THEN
    -- Check the number of withdrawals for the account on the given date
    open c1;
    daily_withdrawal_count :=0;
    loop
      fetch c1 into temp;
      if c1%found then 
        daily_withdrawal_count := daily_withdrawal_count+1;
      end if;
      exit when c1%notfound;
    end loop;
    close c1;
    -- Check constraint (a): Maximum 3 withdrawals per day per account
    IF daily_withdrawal_count >= 3 THEN
      raise_application_error(-20001, 'Maximum of 3 withdrawals reached for account number ' || :new.ano || ' on ' || :new.tdate);
    END IF;

    -- Check constraint (b): Maximum withdrawal amount of Rs.30000
    IF :new.tamount > 30000 THEN
      raise_application_error(-20002, 'Maximum withdrawal amount exceeded. Withdrawal limit for account ' || :new.ano || ' is Rs.30000');
    END IF;
  END IF;
END;
/


rem : violating maximum withdrawal amount
insert into transaction values(2,'S201','W','19-Jan-2023',35000);


insert into transaction values(3,'S103','W','19-Jan-2023',100);
insert into transaction values(4,'S103','W','19-Jan-2023',200);
insert into transaction values(5,'S103','W','19-Jan-2023',300);
rem : exceeding maximum number of withdraws per day
insert into transaction values(6,'S103','W','19-Jan-2023',400);


