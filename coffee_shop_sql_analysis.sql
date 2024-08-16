CREATE DATABASE coffee_shop_sales_db

SELECT * FROM coffee_shop_sales

SET SQL_SAFE_UPDATES=0;
UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date,'%d-%m-%Y');
SET SQL_SAFE_UPDATES=1;

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

describe coffee_shop_sales

UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time,'%H:%i:%s');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

ALTER TABLE coffee_shop_sales
CHANGE COLUMN ï»¿transaction_id transaction_id INT;

SELECT ROUND(SUM(unit_price * transaction_qty)) AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) =5 -- MAY MONTH

-
-- TOTAL SALES KPI -MOM DIFFERENCE AND MOM GROWTH

SELECT 
  MONTH(transaction_date) AS month, 
  ROUND(SUM(unit_price*transaction_qty)) AS total_sales,
  (SUM(unit_price*transaction_qty)-LAG(SUM(unit_price*transaction_qty),1)
  OVER(ORDER BY MONTH(transaction_date)))/LAG(SUM(unit_price*transaction_qty),1)
  OVER(ORDER BY MONTH(transaction_date))*100 AS mom_increase_percentage
FROM
   coffee_shop_sales
WHERE 
  MONTH(transaction_date) IN (4,5)
GROUP BY
  MONTH(transaction_date)
ORDER BY
  MONTH(transaction_date);
  
-- TOTAL ORDERS
SELECT COUNT(transaction_id) AS Total_orders
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5; -- MAY MONTH

-- TOTAL ORDERS KPI-MOM DIFFERENCE AND MOM GROWTH
SELECT
   MONTH(transaction_date) AS month,
   ROUND(COUNT(transaction_id)) AS total_orders,
   (COUNT(transaction_id)-LAG(COUNT(transaction_id),1)
   OVER(ORDER BY MONTH(transaction_date)))/LAG(COUNT(transaction_id),1)
   OVER(ORDER BY MONTH(transaction_date))*100 AS mom_increase_percentage
FROM
  coffee_shop_sales
WHERE
  MONTH(transaction_date) IN (4,5)
GROUP BY
  MONTH(transaction_date)
ORDER BY
  MONTH(transaction_date);
-- TOTAL QUANTITIES SOLD
SELECT SUM(transaction_qty) AS Total_Quantity_Sold
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5; -- FOR MAY MONTH
-- TOTAL QUANTITY SOLD KPI- MOM DIFF AND MOM GROWTH
SELECT
  MONTH(transaction_date) AS month,
  ROUND(SUM(transaction_qty)) AS total_quantity_sold,
  (SUM(transaction_qty)-LAG(SUM(transaction_qty),1)
  OVER(ORDER BY MONTH(transaction_date)))/LAG(SUM(transaction_qty),1)
  OVER(ORDER BY MONTH(transaction_date))*100 AS mom_increase_percentage
FROM
  coffee_shop_sales
WHERE 
  MONTH(transaction_date) IN (4,5)
GROUP BY
  MONTH(transaction_date)
ORDER BY
  MONTH(transaction_date);
-- CALENDER TABLE -DAILY SALES,QUANTITY AND TOTAL ORDERS
SELECT 
  CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'K') AS total_sales,
  CONCAT(ROUND(SUM(transaction_qty)/1000,1),'K')AS total_quantity_sold,
  CONCAT(ROUND(COUNT(transaction_id)/1000,1),'K') AS total_orders
FROM
  coffee_shop_sales
WHERE
  transaction_date='2023-05-18';
-- SALES TREND OVER PERIOD
SELECT AVG(total_sales) AS average_sales
FROM(
   SELECT 
     SUM(unit_price*transaction_qty) AS total_sales
   FROM
     coffee_shop_sales
        WHERE
	 MONTH(transaction_date)=5
	GROUP BY
       transaction_date
) AS internal_query;
-- DAILY SALES FOR MONTH SELECTED
SELECT DAY(transaction_date) AS day_of_month ,ROUND(SUM(unit_price*transaction_qty),1) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date);
-- COMPARING DAILY SALES WITH AVERAGE SALES
SELECT day_of_month,
CASE WHEN total_sales>avg_sales THEN 'Above Average'
     WHEN total_sales<avg_sales THEN 'Below Average'
     ELSE 'Average'
END AS sales_status
FROM(
  SELECT DAY(transaction_date) AS day_of_month,SUM(unit_price*transaction_qty) AS total_sales,
         AVG(SUM(unit_price*transaction_qty)) OVER() AS avg_sales
  FROM coffee_shop_sales
  WHERE MONTH(transaction_date)=5
  GROUP BY DAY(transaction_date)
) AS sales_data
ORDER BY day_of_month;
-- SALES BY WEEKEND/WEEKDAY
SELECT CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
       ELSE 'Weekdays'
       END AS day_type,
       ROUND(SUM(unit_price*transaction_qty),2) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5
GROUP BY
   CASE WHEN dayofweek(transaction_date) IN (1,7) THEN 'Weekends'
        ELSE 'Weekdays'
	END;
-- SALES BY STORE LOCATION
SELECT store_location,SUM(unit_price*transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5
GROUP BY store_location
ORDER BY total_sales DESC;
-- SALES BY PRODUCT CATEGORY
SELECT product_category,ROUND(SUM(unit_price*transaction_qty),1) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5
GROUP BY product_category
ORDER BY total_sales DESC;
-- SALES  BY PRODUCT TOP 10
SELECT product_type,ROUND(SUM(unit_price*transaction_qty),1) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5
GROUP BY product_type
ORDER BY total_sales DESC
LIMIT 10;
-- SALES BY DAY/HOUR
SELECT ROUND(SUM(unit_price*transaction_qty),1) AS total_sales,
       SUM(transaction_qty) AS total_orders,
       COUNT(*) AS total_orders
FROM coffee_shop_sales
WHERE DAYOFWEEK(transaction_date)=3 AND HOUR(transaction_time)=8 AND MONTH(transaction_date)=5;
-- SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
SELECT CASE WHEN DAYOFWEEK(transaction_date)=2 THEN 'Monday'
            WHEN DAYOFWEEK(transaction_date)=3 THEN 'Tuesday'
			WHEN DAYOFWEEK(transaction_date)=4 THEN 'Wednesday'
			WHEN DAYOFWEEK(transaction_date)=5 THEN 'Thursday'
			WHEN DAYOFWEEK(transaction_date)=6 THEN 'Friday'
			WHEN DAYOFWEEK(transaction_date)=7 THEN 'Saturday'
            ELSE 'Sunday'
		END AS Day_of_week, ROUND(SUM(unit_price*transaction_qty)) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5
GROUP BY CASE WHEN DAYOFWEEK(transaction_date)=2 THEN 'Monday'
              WHEN DAYOFWEEK(transaction_date)=3 THEN 'Tuesday'
			  WHEN DAYOFWEEK(transaction_date)=4 THEN 'Wednesday'
			  WHEN DAYOFWEEK(transaction_date)=5 THEN 'Thursday'
			  WHEN DAYOFWEEK(transaction_date)=6 THEN 'Friday'
			  WHEN DAYOFWEEK(transaction_date)=7 THEN 'Saturday'
              ELSE 'Sunday'
		END;
-- SALES FOR ALL HOURS FOR MONTH OF MAY
SELECT HOUR(transaction_time) AS Hour_of_day,ROUND(SUM(unit_price*transaction_qty)) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time);



