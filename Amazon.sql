create database Ecommerce;
use ecommerce;
#14	Identify the top 5 most valuable customers using a composite score that combines three key metrics: (SQL)
#a.	Total Revenue (50% weight): The total amount of money spent by the customer.
#b.	Order Frequency (30% weight): The number of orders placed by the customer, indicating their loyalty and engagement.
#c.	Average Order Value (20% weight): The average value of each order placed by the customer, reflecting the typical transaction size.
WITH CustomerMetrics AS (
  SELECT 
    c.CustomerID, SUM(o.SalePrice) AS TotalRevenue, COUNT(o.OrderID) AS OrderFrequency, AVG(o.SalePrice) AS AverageOrderValue
  FROM customers c JOIN orders o ON c.CustomerID = o.CustomerID GROUP BY c.CustomerID
),RankedCustomers AS (
  SELECT CustomerID, TotalRevenue, OrderFrequency, AverageOrderValue,
    (TotalRevenue * 0.5 + OrderFrequency * 0.3 + AverageOrderValue * 0.2) AS CompositeScore
  FROM CustomerMetrics
)SELECT *
FROM RankedCustomers
ORDER BY CompositeScore DESC
LIMIT 5;
#15.Calculate the month-over-month growth rate in total revenue across the entire dataset. (SQL)
WITH MonthlyRevenue AS (
  SELECT  YEAR(STR_TO_DATE(OrderDate, '%d-%m-%Y')) AS Year,
    MONTH(STR_TO_DATE(OrderDate, '%d-%m-%Y')) AS Month, SUM(SalePrice) AS TotalRevenue
  FROM orders GROUP BY Year, Month
)SELECT Year, Month, TotalRevenue, (TotalRevenue - LAG(TotalRevenue) OVER (ORDER BY Year, Month)) 
   / LAG(TotalRevenue) OVER (ORDER BY Year, Month) * 100 AS MoMGrowthRate
FROM MonthlyRevenue
ORDER BY Year, Month;
#16. Calculate the rolling 3-month average revenue for each product category. (SQL)
with avg_revenue as( SELECT YEAR(STR_TO_DATE(OrderDate, '%d-%m-%Y')) AS Year,
    MONTH(STR_TO_DATE(OrderDate, '%d-%m-%Y')) AS Month,ProductCategory, SUM(SalePrice) AS TotalRevenue
  FROM orders GROUP BY Year, Month, ProductCategory)
  Select year, month, productcategory, avg(totalrevenue) over (partition by productcategory order by year, month rows between 2 preceding 
  and current row ) as rolling3monthavgrevenue
  from avg_revenue order by year, month;
#17.	Update the orders table to apply a 15% discount on the `Sale Price` for 
#orders placed by customers who have made at least 10 orders. (SQL)
Update orders
set saleprice = SalePrice*0.85
where customerID in (select customerid from(select customerid from orders group by customerid having count(orderid)>=10)as temp);
SET SQL_SAFE_UPDATES = 0;
#18.Calculate the average number of days between consecutive orders for customers who have placed at least five orders. (SQL)
WITH CustomerOrders AS (
    SELECT 
        CustomerID, 
        OrderID, 
        OrderDate,
        LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS NextOrderDate
    FROM orders
)SELECT 
    CustomerID,
    AVG(DATEDIFF(NextOrderDate, OrderDate)) AS AvgDaysBetweenOrders
FROM CustomerOrders
WHERE NextOrderDate IS NOT NULL
GROUP BY CustomerID
HAVING COUNT(OrderID) >= 5;
#19.Identify customers who have generated revenue that is more than 30% higher than the average revenue per customer. (SQL)
WITH CustomerRevenue AS (
    SELECT customerid, SUM(saleprice) AS total_revenue
    FROM orders
    GROUP BY customerid
),AverageRevenue AS (SELECT AVG(total_revenue) AS avg_revenue
    FROM CustomerRevenue
)SELECT cr.customerid, cr.total_revenue
FROM CustomerRevenue cr
JOIN AverageRevenue ar ON 1=1
WHERE cr.total_revenue > ar.avg_revenue * 1.3;


-- OBJECTIVE ANSWER 20
SELECT a.ProductCategory, a.TotalSales AS CurrentYearSales,
       b.TotalSales AS PreviousYearSales,
       a.TotalSales - b.TotalSales AS SalesIncrease
FROM (SELECT ProductCategory, SUM(SalePrice) AS TotalSales
     FROM orders
     WHERE YEAR(STR_TO_DATE(OrderDate, '%d-%m-%Y')) = 2020
     GROUP BY ProductCategory) a
JOIN (SELECT ProductCategory, SUM(SalePrice) AS TotalSales
     FROM orders
     WHERE YEAR(STR_TO_DATE(OrderDate, '%d-%m-%Y')) = 2019
     GROUP BY ProductCategory) b
ON a.ProductCategory = b.ProductCategory
ORDER BY SalesIncrease DESC
LIMIT 3;

select status from orders











