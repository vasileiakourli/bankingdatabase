-- Vasileia Kourli 3130101

-- Exw dimiourgisei tin vasi apo to script_A.sql pou mas dothike (me moni allagi tin prosthiki tou local stin entoli load data)
-- me ta dedomena tou datasetA.txt
-- Prosthetw kai ta dedomena tou datasetB.txt kai ektelw ta erwtimata
-- Arxikopoiw ek neou ti vasi me ta dedomena tou datasetA.txt kai epeita kanw ta eksis.  

-- create a temporary import table_B

CREATE TABLE import_table_B (
	customer_id VARCHAR(20),
    customer_name VARCHAR(50),
    customer_surname VARCHAR(50),
    customer_gender CHAR(1),
    customer_city VARCHAR(50),
    customer_age INT,
    customer_marital_status CHAR(1),
    customer_children INT,
    customer_education INT,
    account_id VARCHAR(20),
    account_open_date DATE,
    account_cards_linked INT,
    account_currency CHAR(3),
    product_code CHAR(4),
    product_name VARCHAR(50),
    branch_code CHAR(4),
    branch_number_employees INT,
    branch_city VARCHAR(50),
    trn_code CHAR(22),
    trn_type CHAR(1),
    trn_amount DOUBLE,
    trn_date DATE,
    account_current_balance DOUBLE
);

-- load data from text file datasetB to import_table_B

LOAD DATA LOCAL INFILE 'C:\datasetB.txt'
-- Dataset Path
INTO TABLE import_tableB 
FIELDS TERMINATED BY '|' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(customer_id,customer_name,customer_surname,customer_gender,customer_city,customer_age,customer_marital_status,customer_children,customer_education,account_id,@var1,
account_cards_linked,account_currency,product_code,product_name,branch_code,branch_number_employees,branch_city,trn_code,trn_type,trn_amount,@var2,account_current_balance) 
SET account_open_date = STR_TO_DATE(@var1, '%d/%m/%Y'), trn_date = STR_TO_DATE(@var2, '%d/%m/%Y');

-- Create index1 
CREATE INDEX index1 ON transactions(account_id,trn_date);

-- Create index2
CREATE INDEX index2 ON accounts(account_id,branch_code);

-- load tables with the new data

INSERT INTO branches SELECT DISTINCT branch_code, branch_number_employees, branch_city
FROM import_table_B WHERE branch_code NOT IN(SELECT branch_code FROM branches );  

INSERT INTO products SELECT DISTINCT product_code, product_name
FROM import_table_B WHERE product_code NOT IN(SELECT product_code FROM products );  

INSERT INTO customers SELECT DISTINCT customer_id, customer_name, customer_surname, customer_gender, customer_city, customer_age, customer_marital_status, customer_children, customer_education
FROM import_table_B WHERE customer_id NOT IN(SELECT customer_id FROM customers );  

INSERT INTO accounts SELECT DISTINCT account_id, account_open_date, account_cards_linked, account_currency, customer_id, branch_code, product_code
FROM import_table_B WHERE account_id NOT IN(SELECT account_id FROM accounts );  

INSERT INTO transactions SELECT DISTINCT trn_code, trn_type, trn_amount, trn_date, account_current_balance, account_id
FROM import_table_B WHERE trn_code NOT IN(SELECT trn_code FROM transactions );


-- drop temporary import table
DROP TABLE import_table_B;

-- Queries

-- 1
SELECT branches.branch_code, branches.branch_city, AVG(trn_amount) 
FROM branches, products, accounts, transactions 
WHERE product_name='Beta600' AND trn_type='D' 
AND transactions.account_id=accounts.account_id AND accounts.product_code= products.product_code 
AND accounts.branch_code= branches.branch_code AND YEAR(trn_date)<=2014 AND YEAR(trn_date)>=2010 
group by branch_code 
ORDER BY AVG(trn_amount) DESC limit 1;

-- 2
 SELECT customers.customer_id, customer_name, customer_surname 
 FROM customers, accounts, transactions 
 WHERE MONTH(trn_date)=MONTH(current_date()) AND YEAR(trn_date)=YEAR(DATE_SUB(current_date(), INTERVAL 5 YEAR)) 
 AND transactions.account_id= accounts.account_id 
 AND accounts.customer_id= customers.customer_id 
 GROUP BY customer_id;

-- 3
SELECT branches.branch_code, MAX(trn_amount) 
FROM branches, transactions, accounts, products
WHERE trn_date <= '2010-01-01' AND product_name='SmileKids' AND trn_type='C' 
AND accounts.product_code= products.product_code AND accounts.branch_code= branches.branch_code
AND transactions.account_id= accounts.account_id 
GROUP BY branch_code 
ORDER BY MAX(trn_amount) DESC
limit 1;

-- 4
SELECT SUM(trn_amount), customer_gender, branches.branch_code, MONTH(trn_date), YEAR(trn_date) 
FROM customers, branches, products, accounts, transactions 
WHERE account_currency='EUR' AND product_name='Beta600' 
AND trn_type='D' 
AND accounts.customer_id = customers.customer_id
AND accounts.branch_code = branches.branch_code
AND accounts.product_code = products.product_code 
AND transactions.account_id = accounts.account_id
AND trn_date<'2012-01-01' 
GROUP BY customer_gender, branches.branch_code, MONTH(trn_date), YEAR(trn_date);

-- 5
SELECT MAX(trn_date), accounts.account_id , trn_code from transactions,accounts
where account_cards_linked>1 AND account_currency='USD' 
AND transactions.account_id= accounts.account_id 
and trn_code in(SELECT MAX(trn_code) from accounts, transactions
where account_cards_linked>1 AND account_currency='USD' and transactions.account_id= accounts.account_id group by accounts.account_id,trn_date)
GROUP BY accounts.account_id;