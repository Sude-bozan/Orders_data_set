select * from df_orders


--Find top 10 highest revenue generating products
SELECT product_id, SUM(sales_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;


--find top 5 highest-selling products in each region
with cte as(
SELECT region, 
       product_id,
       SUM(sales_price) AS total_sales
FROM df_orders
GROUP BY region, product_id)
select* from(
select *
, row_number() over (partition by region order by total_sales desc) as rn
from cte) A
where rn<=5;


--find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 and jan 2023
WITH cte AS ( 
  SELECT 
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    TO_CHAR(order_date, 'MONTH') AS month_string,  -- order_date'den ayı 'MM' formatında string olarak alır
    SUM(sales_price) AS total_sales
FROM 
    df_orders
GROUP BY 
    EXTRACT(YEAR FROM order_date), 
    EXTRACT(MONTH FROM order_date), 
    TO_CHAR(order_date, 'MONTH')
)
SELECT order_month,
       month_string,
       SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) AS sales_2022,
       SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY month_string, order_month
ORDER BY order_month;


--for each category which month had highest sales
with cte as(
select category,
         TO_CHAR(order_date, 'YYYY-MM') AS year_month,
		 sum(sales_price) as sales
from df_orders
group by 1,2 )
select * from (
select *,
row_number () over (partition by category order by sales desc) as rn 
from cte ) a
where rn=1



--which sub category had highest growth by profit in 2023 compare to 2022
WITH cte AS (
  SELECT sub_category,
  EXTRACT(YEAR FROM order_date) AS order_year,
         SUM(sales_price) AS total_sales
  FROM df_orders
  GROUP BY sub_category, order_year
), cte2 as (
SELECT sub_category,
       SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) AS sales_2022,
       SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY sub_category
)
select *,
(sales_2023 - sales_2022)*100/sales_2022 as growth_percent
from cte2
order by growth_percent desc
;


