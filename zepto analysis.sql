drop table if exists zepto;

create table zepto(
SKU_ID SERIAL primary key, category varchar(30),name varchar(30) not null,mrp numeric(8,2),
discountPercent numeric (3,2), availableQuantity int,discountedSellingPrice numeric(8,2),
weightInGms int ,outOfStock boolean ,quantity int);

                                  -- data exploration --

--count of rows
select count (*) from zepto;


--Sample data
Select * from zepto limit 10;


--null values
select * from zepto where 
category is null or
name is null or
mrp is null or
discountPercent is null or
availableQuantity is null or
discountedSellingPrice is null or
weightInGms is null or
outOfStock is null or
quantity is null;


--different product categories
select distinct category from zepto 
order by category;


--product in stock vs out of stock
Select outOfStock ,count (SKU_ID) from zepto group by outOfStock;


--product name repeated how many time
select name, count (SKU_ID) from zepto group by name;


--products name presented multiple times
select name , count (SKU_ID) from zepto group by name 
having count (SKU_ID) > 1 ;

-- using orders (asc/desc)
select name , count (SKU_ID) from zepto group by name 
having count (SKU_ID) > 1 
order by count (SKU_ID) asc;

-- checking invalid pricing
select from zepto where mrp < discountedSellingPrice;

                                      -- data CLeaning --

--products with zero price
select * from zepto where mrp = 0;

-- deleting a row
delete from zepto where mrp = 0;

-- converting rupees from paise
update zepto set mrp = mrp/100.0 ,
discountedSellingPrice = discountedSellingPrice/100.0;
select * from zepto ;

--checking inventory consistency
select distinct sku_id,name,category,availableQuantity
from zepto where availableQuantity > quantity
order by availableQuantity desc;

--does the stock flag makes sense:
select from zepto where outOfStock = true and availableQuantity >0;
 

                                  -- analysis --
								  
-- Q1.Find the top 10 best-value products based on the discount percentage.
select distinct name,mrp,discountPercent from zepto
order by discountPercent desc limit (10);

--Q2.What are the Products with High MRP but Out of Stock.
select * from zepto where outOfStock=true 
order by mrp desc limit (10);

--Q3.Calculate Estimated Revenue for each category
select category ,sum (discountedSellingPrice * availableQuantity) as total_revenue from zepto
group by category
order by total_revenue;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.
select distinct name, mrp,discountPercent from zepto where mrp >500 and discountPercent <10 order by mrp desc ,discountPercent
desc ;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.
SELECT category,
ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC 
LIMIT 5;

-- Q6. Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

--Q7.Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name, weightInGms,
CASE WHEN weightInGms < 1000 THEN 'Low'
	WHEN weightInGms < 5000 THEN 'Medium'
	ELSE 'Bulk'
	END AS weight_category
FROM zepto;

--Q8.What is the Total Inventory Weight Per Category 
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;

