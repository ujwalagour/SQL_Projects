## 1.Find customers who have never ordered

Select name from users 
where user_id NOT IN (select user_id from orders);

############################

## 2. Average Price/dish

# first we find average price per dish with food id

select f_id, avg(price) 
from menu group by f_id;

## The Final answer with Food name

select any_value(f_name), Avg(price) 
from menu as m
JOIN food as f
ON m.f_id = f.f_id
Group by m.f_id;

###############################

## 3.Find the top restaurant in terms of the number of orders for a given month

# step by step solution

# First extract month from date column 
Select * , monthname(date) As 'month' 
From orders2
Where monthname(date) Like 'June'; 

# The final answer
Select any_value(r_name), count(*) As'Month'
From orders2 o 
Join restaurant r 
on o.r_id= r.r_id 
where monthname(date) Like 'june' 
group by o.r_id 
order by count(*) desc limit 1;

###############################

## 4. restaurants with monthly sales greater than x for

select any_value(r.r_name), sum(amount) As 'revenue' 
From orders2 o 
Join restaurant r ON o .r_id = r.r_id 
where Monthname(date) Like 'JuNe' 
Group By o.r_id 
Having revenue > 500;

################################

## 5. Show all orders with order details for a particular customer in a particular date range

## Step by Step 

## filter data by user name 'Nitish' i.e.  how many order done by Nitish the month range is june to july.

Select * From orders2 
where user_id = ( select user_id from users where name Like 'Nitish') 
And (Date > '2022-06-10'  AND date < '2022-07-10');

## Detail of these orders with restaurant name
Select o.order_id, r.r_name  From orders2 o
Join restaurant r 
On r.r_id = o.r_id
where user_id = ( select user_id from users where name Like 'Nitish') 
And (Date > '2022-06-10'  AND date < '2022-07-10');

# Final answer: Oder history of customer name Nitish

Select o.order_id, r.r_name, f.f_name
From orders2 o
Join restaurant r 
On r.r_id = o.r_id
Join order_details od
On o.order_id = od.order_id
Join food f
On f.f_id = od.f_id
where user_id = ( select user_id from users where name Like 'Nitish') 
And (Date > '2022-06-10'  AND date < '2022-07-10');

################################

## 6. Find restaurants with maximum repeated customers 

## Visits column tell us that how many times a particular user visits (order placed) a particular restaurant
select r_id, user_id, count(*) As 'visits' 
from orders2 
Group by r_id, User_id;

## using having clause, here we display those combinations where visitors are greater than 
select r_id, user_id, count(*) As 'visits' 
from orders2 
Group by r_id, User_id
Having visits > 1;

## We have to find mode 
Select r_id, Count(*) As 'loyal_customers'
From (
       select r_id, user_id, count(*) As 'visits' 
       from orders2 
	   Group by r_id, User_id
	   Having visits > 1
     ) t 
Group by r_id
order by loyal_customers desc limit 1;

# final answer

Select any_value(r_name), Count(*) As 'loyal_customers'
From (
       select r_id, user_id, count(*) As 'visits' 
       from orders2 
	   Group by r_id, User_id
	   Having visits > 1
     ) t 
Join restaurant r 
On r.r_id = t.r_id
Group by t.r_id
order by loyal_customers desc limit 1;

##############################

## 7. Month over month revenue growth of swiggy

## month by month total 
select monthname(date) As 'Month', sum(amount) As 'Revenue'
from orders2
group by Month;

## final answer

Select month,((revenue - prev)/prev)*100 
from 
(
With sales As
(
select monthname(date) As 'Month', sum(amount) As 'Revenue'
from orders2
group by Month
)
Select Month, Revenue, LAG(Revenue,1) 
over(order by Revenue) As 'prev'
From sales
) t ;

##############################

## 8. Customer - favourit food.

## The following query display that a particular user how many times order a particular food.
select o.user_id, od.f_id, Count(*) As 'frequency'
from orders2 o 
Join order_details od 
ON o.order_id = od.order_id
Group by o.user_id, od.f_id;

## The following query used to display highest frequency number
with temp As 
(
select o.user_id, od.f_id, Count(*) As 'frequency'
from orders2 o 
Join order_details od 
ON o.order_id = od.order_id
Group by o.user_id, od.f_id
) 
select * 
from temp t1 
where t1.frequency = (Select MAX(frequency) 
from temp t2 
where t2.user_id=t1.user_Id);


## Final Answer

with temp As 
(
	select o.user_id, od.f_id, Count(*) As 'frequency'
	from orders2 o 
	Join order_details od 
	ON o.order_id = od.order_id
	Group by o.user_id, od.f_id
) 
select u.name, u.user_id, f.f_name, t1.frequency from 
temp t1 
Join users u
ON u.user_id  = t1.user_id
Join food f
ON f.f_id = t1.f_id
where t1.frequency = (select max(frequency)
   from temp t2 
   where t2.user_id = t1.user_id
   )
order by u.user_id;