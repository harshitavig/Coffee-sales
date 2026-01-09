SELECT * 
FROM coffee_shop_sales

DESCRIBE coffee_shop_sales

#FROM TEXT TO DATE AND TIME DATATYPE
UPDATE coffee_shop_sales
SET transaction_time=str_to_date(transaction_time,'%H:%i:%s');

ALTER TABLE coffee_shop_sales
CHANGE COLUMN ï»¿transaction_id transaction_id int;

#KPI'S
#TOTAL SALES
SELECT sum(unit_price * transaction_qty)as total_quantity
FROM coffee_shop_sales
WHERE month(transaction_date)=5;

#MOM FOR TOTAL SALES OF CURRENT-PREVIOUS
SELECT 
  month(transaction_date) as month,
  round(sum(unit_price * transaction_qty)) as total_sales,
  (sum(unit_price * transaction_qty)-lag(sum(unit_price * transaction_qty))
  over (order by month(transaction_date)))/lag(sum(unit_price * transaction_qty))
  over(order by month(transaction_date))*100 as mom_increase_percentage

FROM coffee_shop_sales
WHERE month(transaction_date) in (4,5)
GROUP BY month(transaction_date)
ORDER BY month(transaction_date)
   

#TOTAL QUANTITY
SELECT sum(transaction_qty)as total_quantity
FROM coffee_shop_sales
WHERE month(transaction_date)=5;

#MOM FOR CURRENT-PREVIOUS
SELECT 
  month(transaction_date) as month,
  round(sum(transaction_qty)) as total_quantity,
  (sum(transaction_qty)-lag(sum(transaction_qty))
  over (order by month(transaction_date)))/lag(sum(transaction_qty))
  over(order by month(transaction_date))*100 as mom_increase_percentage

FROM coffee_shop_sales
WHERE month(transaction_date) in (4,5)
GROUP BY month(transaction_date)
ORDER BY month(transaction_date)
 
 
 #TOTAL ORDERS
SELECT count(transaction_id)as total_orders
FROM coffee_shop_sales
WHERE month(transaction_date)=5;

#MOM
SELECT 
  month(transaction_date) as month,
  round(count(transaction_id)) as total_quantity,
  ( count(transaction_id)-lag( count(transaction_id))
  over (order by month(transaction_date)))/lag( count(transaction_id))
  over(order by month(transaction_date))*100 as mom_increase_percentage

FROM coffee_shop_sales
WHERE  month(transaction_date) in (4,5)
GROUP BY month(transaction_date)
ORDER BY month(transaction_date)
 
 
 
 
 
 
 #CHARTS 
 #1.CALENDAR HEAT MAP
SELECT
   concat(round(sum(unit_price * transaction_qty)/1000,1),'k') as total_sales,
   concat(round(sum(transaction_qty)/1000,1),'k') as total_quantity,
   concat(round(count(transaction_id)/1000,1),'k') as total_orders
FROM coffee_shop_sales  
WHERE transaction_date='2023-05-18' 

#2.SALES IN WEEKDAYS AND WEEKENDS
SELECT
    CASE when dayofweek(transaction_date) in (1,7)then 'Weekends'
    else 'weekdays'
    end as day_type,
    concat(round(sum(unit_price * transaction_qty)/1000,1),'k') as total_sales
    from coffee_shop_sales
    where month(transaction_date)=5
    group by 
    case when dayofweek(transaction_date) in (1,7)then 'Weekends'
    else 'weekdays'
    end
    
#3.SALES ANALYSIS BY STORE LOCATION
SELECT 
   store_location,
   concat(round(sum(unit_price * transaction_qty)/1000,1),'k') as total_sales
FROM coffee_shop_sales
WHERE month(transaction_date)=3
GROUP BY store_location
ORDER BY sum(unit_price * transaction_qty) desc   


#4.DAILY SALES ANALYSIS WITH AVERAGE LINE
SELECT 
    concat(round(avg(total_sales)/1000,1),'k') as avg_sales
FROM
    (select sum(unit_price * transaction_qty) as total_sales
    from coffee_shop_sales
    where month(transaction_date)=5
    group by transaction_date
    ) as internal_query
    
    
    
SELECT 
    day_of_month,
    case
      when total_sales>avg_sales then 'above average'
       when total_sales<avg_sales then 'below average'
       else 'average'
       end as sales_status,
       total_sales
       FROM
       (select
            day(transaction_date) as day_of_month,
			sum(unit_price * transaction_qty) as total_sales,
            avg(sum(unit_price * transaction_qty)) over() as avg_sales
            from coffee_shop_sales
            where month(transaction_date)=5
            group by day(transaction_date)
       )as sales_data
       ORDER BY day_of_month
   
   
   #5.SALES BY PRODUCT CATEGORY
   SELECT
    product_category,
    concat(round(sum(unit_price*transaction_qty)/1000,1),'k') as total_sales
    FROM coffee_shop_sales
    WHERE month(transaction_date)=5
    GROUP BY product_category
    ORDER BY sum(unit_price*transaction_qty) desc
    
#TOP 10 PRODUCTS
	SELECT
    product_type,
    concat(round(sum(unit_price*transaction_qty)/1000,1),'k') as total_sales
    FROM coffee_shop_sales
    WHERE month(transaction_date)=5 and product_category='coffee'
    GROUP BY product_type
    ORDER BY sum(unit_price*transaction_qty) desc
    LIMIT 10
    
    
    
#7.SALES BY DAYS /HOURS
SELECT
   concat(round(sum(unit_price * transaction_qty)/1000,1),'k') as total_sales,
   concat(round(sum(transaction_qty)/1000,1),'k') as total_quantity,
   concat(round(count(transaction_id)/1000,1),'k') as total_orders
FROM coffee_shop_sales
WHERE month(transaction_date)=5   
 AND dayofweek(transaction_date)=1  
 AND hour(transaction_time)=8 

#GRAPH m HOURS DEKHNE K LIYE
SELECT
  hour(transaction_time),
  sum(unit_price * transaction_qty)
FROM coffee_shop_sales
WHERE month(transaction_date)=5
GROUP BY hour(transaction_time)
ORDER BY hour(transaction_time)
  
#GRAPH m DAYS DEKHNE K LIYE
SELECT 
   case 
      when dayofweek(transaction_date) =2 then 'monday'
      when dayofweek(transaction_date) =3 then 'tuesday'
      when dayofweek(transaction_date) =4 then 'wednesday'
      when dayofweek(transaction_date) =5 then 'thursday'
      when dayofweek(transaction_date) =6 then 'friday'
      when dayofweek(transaction_date) =7 then 'saturday'
      else 'sunday'
   end as days_of_week,
   round(sum(unit_price*transaction_qty)) as total_sales
FROM coffee_shop_sales
WHERE month(transaction_date)=5
GROUP BY
  case
      when dayofweek(transaction_date) =2 then 'monday'
      when dayofweek(transaction_date) =3 then 'tuesday'
      when dayofweek(transaction_date) =4 then 'wednesday'
      when dayofweek(transaction_date) =5 then 'thursday'
      when dayofweek(transaction_date) =6 then 'friday'
      when dayofweek(transaction_date) =7 then 'saturday'
   else 'sunday'  
   end;   
      
USE coffee_shop_sales_db
     