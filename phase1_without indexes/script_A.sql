# Kourli Vasileia
# 3130101

#Create Database

CREATE DATABASE BankDB;

USE BankDB;

#Create a temporary table for loading data

CREATE TABLE temp(
	Customer_id INTEGER,
    FirstName VARCHAR(20),
    Lastname VARCHAR(20),
    Gender VARCHAR(1),
    Customer_City VARCHAR(20),
    Age INTEGER,
    Marital_Status VARCHAR(1),
    Children INTEGER,
    Educational VARCHAR(1),
    Account_id NUMERIC(20,0),
    OpenDate VARCHAR(20),
	Cards_Linked INTEGER,
    Currency VARCHAR(20),
    Product_Code INTEGER,
    Product_Name VARCHAR(20),
    Branch_Code INTEGER,
    NumberOfEmployees INTEGER,
    Branch_City VARCHAR(20),
    Trn_Code  NUMERIC(20,0),
    Trn_Type VARCHAR(1),
    Trn_Amount NUMERIC(12,2),
    Trn_Date VARCHAR(20),
    Current_Balance NUMERIC(12,2)
);

#Load data from datasetA.txt into our temporary table

LOAD DATA LOCAL INFILE 'C:/Users/PUBLIC.notebook/Desktop/datasetA.txt' INTO TABLE temp FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n' IGNORE 1 LINES;


CREATE TABLE customers(
	Customer_id INTEGER,
    FirstName VARCHAR(20),
    Lastname VARCHAR(20),
    Gender VARCHAR(1),
    Customer_City VARCHAR(20),
    Age INTEGER,
    Marital_Status VARCHAR(1),
    Children INTEGER,
    Educational VARCHAR(1),
    PRIMARY KEY(Customer_id),
    CONSTRAINT ch1_cust CHECK(Gender='M' OR Gender='F'),
    CONSTRAINT ch2_cust CHECK(Educational=1 OR Educational=2 OR Educational=3 ),
    CONSTRAINT ch3_cust CHECK(Marital_Status='M' OR Marital_Status='S')
);

INSERT INTO customers SELECT DISTINCT(Customer_id),FirstName, Lastname, Gender, Customer_City, Age, Marital_Status, Children, Educational FROM temp;


CREATE TABLE products(
	Product_Code INTEGER,
    Product_Name VARCHAR(20),
    PRIMARY KEY(Product_Code)
);

INSERT INTO products SELECT DISTINCT(Product_Code),Product_Name FROM temp;

CREATE TABLE branch(
	Branch_Code INTEGER,
    NumberOfEmployees INTEGER,
    Branch_City VARCHAR(20),
    PRIMARY KEY(Branch_Code)
);

INSERT INTO branch SELECT DISTINCT(Branch_Code), NumberOfEmployees, Branch_City FROM temp;

CREATE TABLE accounts(
	Account_id NUMERIC(20,0),
    Customer_id INTEGER,
    Product_Code INTEGER,
    Branch_Code INTEGER,
    OpenDate VARCHAR(20),
	Cards_Linked INTEGER,
    Currency VARCHAR(20),
    PRIMARY KEY(Account_id),
    CONSTRAINT FK_customers FOREIGN KEY (Customer_id) REFERENCES customers(Customer_id),
    CONSTRAINT FK_products FOREIGN KEY (Product_Code) REFERENCES products(Product_Code),
    CONSTRAINT FK_branch FOREIGN KEY (Branch_Code) REFERENCES branch(Branch_Code)
);

INSERT INTO accounts SELECT DISTINCT(Account_id), Customer_id, Product_Code, Branch_Code, OpenDate, Cards_Linked, Currency FROM temp;

CREATE TABLE trn(
	Trn_Code NUMERIC(20,0),
    Trn_Type VARCHAR(1),
	Trn_Amount NUMERIC(12,2),
	Trn_Date VARCHAR(20),
	Current_Balance NUMERIC(12,2),
    Account_id NUMERIC(20,0),
    PRIMARY KEY(Trn_Code),
    CONSTRAINT ch1_trn CHECK(Trn_Type='D' OR Trn_Type='C'),
	CONSTRAINT FK_trn FOREIGN KEY (Account_id) REFERENCES accounts(Account_id)
);

INSERT INTO trn SELECT DISTINCT(Trn_Code), Trn_Type, Trn_Amount, Trn_Date, Current_Balance,Account_id FROM temp;

DROP TABLE temp;

#Answers

#1
select count(distinct customers.Customer_id) from customers,accounts where customers.Customer_id=accounts.Customer_id and '2010-01-01'>STR_TO_DATE(OpenDate, '%d/%m/%Y') ; 

#2
select Product_Name, COUNT(Account_id) from products, accounts where products.Product_Code = accounts.Product_Code group by Product_Name order by count(Account_id) limit 1 ;

#3
select branch.Branch_Code from branch, customers, accounts where customers.Customer_id=accounts.Customer_id and accounts.Branch_Code = branch.Branch_Code group by branch.Branch_Code order by count(customers.Customer_id) desc limit 5;

#4
select branch.Branch_Code from products, branch, accounts, trn where accounts.Account_id = trn.Account_id and products.Product_Code = accounts.Product_Code and branch.Branch_Code = accounts.Branch_Code and Product_Name = 'Beta600' and STR_TO_DATE(Trn_Date, '%d/%m/%Y')>='2015-01-01' group by branch.Branch_Code order by sum(Current_Balance) desc limit 1;
