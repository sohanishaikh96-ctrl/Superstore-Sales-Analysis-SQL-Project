
USE RetailDB

select * from ['superstore']

--Creating the Customers table

CREATE TABLE Customers (
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Segment VARCHAR(50)
);

--Creating the Locations table

CREATE TABLE Locations (
    Postal_Code INT ,
    Country VARCHAR(50),
    State VARCHAR(50),
    City VARCHAR(50),
    Region VARCHAR(50)
);

--Creating the Products table

CREATE TABLE Products (
    Product_ID VARCHAR(30) ,
    Product_Name VARCHAR(255),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50)
);

--Creating the Orders table

CREATE TABLE Orders (
    Order_ID VARCHAR(20) PRIMARY KEY,
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode VARCHAR(30),
    Customer_ID VARCHAR(20),
    Postal_Code INT,
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    );

--Creating the Order_Details table

CREATE TABLE Order_Details (
    Order_ID VARCHAR(20),
    Product_ID VARCHAR(30),
    Sales DECIMAL(10,2),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
);


INSERT INTO Customers
SELECT DISTINCT
    Customer_ID,
    Customer_Name,
    Segment
FROM ['superstore'];

INSERT INTO Products
SELECT DISTINCT
    Product_ID,
    Product_Name,
    Category,
    Sub_Category
FROM ['superstore'];

INSERT INTO Locations
SELECT DISTINCT
    Postal_Code,
    Country,
    State,
    City,
    Region
FROM ['superstore'];

INSERT INTO Orders
SELECT DISTINCT
    Order_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Customer_ID,
    Postal_Code
FROM ['superstore'];

INSERT INTO Order_Details
SELECT
    Order_ID,
    Product_ID,
    Sales
FROM ['superstore'];

SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Locations;
SELECT * FROM Orders;
SELECT * FROM Order_Details;

--CALCULATING TOTAL SALES 
SELECT SUM(Sales) AS Total_sales
FROM Order_Details

--CALCULATING SALES BY SHIPPING MODE AND COUNT OF ORDERS
SELECT o.Ship_Mode, count(od.Order_ID) as CountOfOrders , 
SUM(od.Sales) as TotalSales
FROM Orders o 
JOIN Order_Details od 
on o.Order_ID = od.Order_ID
GROUP BY Ship_Mode 
ORDER BY CountOfOrders desc --Standard_class has generated highest number of orders and sales 

--TOTAL CUSTOMERS 
SELECT COUNT(*) AS Total_Customers
FROM Customers;--793

--TOTAL PRODUCTS
SELECT COUNT(*) AS Total_Products
FROM Products; -- 1894

--TOP 10 CUSTOMERS BY SALES 
SELECT TOP 10 c.Customer_ID, c.Customer_Name ,
    SUM(od.Sales) as Total_Sales
FROM Customers c 
JOIN Orders o ON c.Customer_ID = o.Customer_ID
JOIN Order_Details od ON o.Order_ID = od.Order_ID
GROUP BY c.Customer_ID , Customer_Name
ORDER BY Total_Sales Desc 

--TOP 10 SELLING PRODUCTS
SELECT TOP 10 p.product_name, SUM(od.Sales) as Total_Sales
FROM Products p 
JOIN Order_Details od 
on p.Product_ID = od.Product_ID
GROUP BY p.Product_Name 
ORDER BY Total_Sales Desc

--SALES BY CATEGORY 
SELECT p.Category,SUM(od.Sales) as Total_Sales
FROM Products p 
JOIN Order_Details od 
on p.Product_ID = od.Product_ID
GROUP BY p.Category 
ORDER BY Total_Sales Desc

--SALES BY SUB-CATEGORY 
WITH Salesbysutcat as (
SELECT p.Sub_Category,SUM(od.Sales) as Total_Sales
FROM Products p 
JOIN Order_Details od 
on p.Product_ID = od.Product_ID
GROUP BY p.Sub_Category )

SELECT top 5 Sub_Category 
FROM Salesbysutcat
ORDER BY Total_Sales DESC 

--CREATING A VIEW FOR SALES BY REGION

CREATE VIEW Regions as 
SELECT l.region, SUM(od.Sales) as Total_Sales
FROM Locations l 
JOIN Orders o 
on l.Postal_Code = o.Postal_Code
JOIN Order_Details od 
on o.Order_ID = od.Order_ID
GROUP BY l.region

SELECT * FROM Regions

--SALES BY STATE
SELECT l.State, SUM(od.Sales) as Total_Sales
FROM Locations l 
JOIN Orders o 
on l.Postal_Code = o.Postal_Code
JOIN Order_Details od 
on o.Order_ID = od.Order_ID
GROUP BY l.State
ORDER BY Total_Sales DESC

--SALES BY SEGMENT 
SELECT c.Segment, SUM(od.Sales) AS Total_Sales
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
JOIN Order_Details od
ON o.Order_ID = od.Order_ID
GROUP BY c.Segment
ORDER BY Total_Sales DESC

--MONTHLY SALES TREND 
SELECT YEAR(order_date) as Years , MONTH(order_date) as Months,
SUM(od.Sales) As Total_sales
FROM Orders o 
JOIN Order_Details od 
on o.Order_ID = od.Order_ID 
GROUP BY YEAR(order_date),MONTH(order_date)
Order by years, Months

--Finding Products whose sale is greater than Average Sale
SELECT p.Product_ID, p.product_name ,od.Sales
FROM products p
JOIN Order_Details od 
On p.Product_ID = od.Product_ID
where sales > (SELECT round(AVG(Sales),2) from Order_Details)

--Finding repeat Customers 
SELECT c.Customer_Name , COUNT(o.Order_ID) as CountofOrder
FROM Customers c
JOIN Orders o 
on c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_Name
HAVING COUNT(o.Order_ID) > 1
Order by CountofOrder

---Finding Products that was never Ordered 
SELECT product_id , product_name
FROM Products 
WHERE Product_ID 
not in (SELECT product_ID FROM Order_Details)

---Ranking Customers by Count of Orders 
SELECT c.customer_name , Count(o.order_id) as CountOfOrders,
DENSE_RANK() OVER(Order By Count(o.order_id) DESC) Customer_Rank
FROM Customers c 
JOIN Orders o 
On c.Customer_ID = o.Customer_ID
GROUP By Customer_Name

--Categorising Customers 
CREATE VIEW Customer_Category AS 
SELECT c.customer_name, sum(od.sales) As Total_sales,
    CASE
        WHEN SUM(od.Sales) >= 1500000 THEN 'High Value Customer'
        WHEN SUM(od.Sales) >= 500000 THEN 'Normal Value Customer'
        ELSE 'Low Value Customer'
    END AS Customer_Category
FROM Customers c
JOIN Orders o on c.Customer_ID = o.Customer_ID
JOIN Order_Details od on o.Order_ID = od.Order_ID
GROUP By c.customer_name 

SELECT * From Customer_Category

SELECT Customer_Category,Count(*) as Counts
From Customer_Category
Group by Customer_Category
Order by Customer_Category Desc

---Running Total Sales
SELECT p.product_id, p.product_name , o.order_date,
SUM(od.sales) over(order by o.order_date rows between unbounded preceding and current row) as Running_Total
From Products p 
JOIN Order_Details od on p.Product_ID = od.Product_ID
JOIN Orders o on o.Order_ID = od.Order_ID

--Finding Average days for getting order shipped by State
SELECT distinct l.state , AVG(DATEDIFF(DAY,o.order_date,o.ship_date)) avg_days
FROM Locations l 
JOIN Orders o on l.Postal_Code = o.Postal_Code
Group by State
Order by avg_days 

---Calculating sales over the year 
SELECT YEAR(o.order_date) as Years,
SUM(od.sales) as Total_sales
FROM Orders o 
JOIN Order_Details od 
on o.Order_ID = od.Order_ID
Group by YEAR(o.order_date)
Order by Years 

--Calculating Sales and Count of order According to States
SELECT l.State, SUM(od.Sales) as Total_Sales , COUNT(o.order_id) as CountOfOrder 
FROM Locations l 
JOIN Orders o ON l.Postal_Code = o.Postal_Code 
JOIN Order_Details od ON o.Order_ID = od.Order_ID
GROUP By l.State
ORDER By Total_Sales DESC

--Checking which customer has never placed the order 
SELECT customer_id, customer_name 
FROM Customers
WHERE Customer_ID NOT IN (SELECT Customer_ID FROM Orders)

--Creating Stored Procedure for checking sales by customer_id 
CREATE PROCEDURE GetCustomerSales
@customerid VARCHAR(20)
AS 
    BEGIN
        SELECT c.Customer_ID, c.Customer_Name,
        SUM(od.Sales) AS Total_Sales
        FROM Customers c
        JOIN Orders o
        ON c.Customer_ID = o.Customer_ID
        JOIN Order_Details od
        ON o.Order_ID = od.Order_ID
        WHERE c.Customer_ID = @CustomerID
        GROUP BY c.Customer_ID, c.Customer_Name
     END

EXEC GetCustomerSales 'AB-10165'

--Creating store procedure wiht Date Range 
CREATE PROCEDURE GetSalesBetween 
@StartDate date,
@EndDate date
AS 
    BEGIN
        SELECT SUM(od.sales) as Total_sales
        FROM Orders o
        JOIN Order_Details od 
        ON o.Order_ID = od.Order_ID
        WHERE o.Order_Date BETWEEN @StartDate AND @EndDate
    END

EXEC GetSalesBetween '01-01-2015','12-31-2015'