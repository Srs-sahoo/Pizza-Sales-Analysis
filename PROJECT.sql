create database PROJECT;
use PROJECT;

--BASIC_QUESTION--

----Retrieve the total number of orders placed.

select count(order_id) as total_order from dbo.orders;

--Calculate the total revenue generated from pizza sales.

ALTER TABLE pizzas ALTER COLUMN price NUMERIC(5,3);

select ROUND(SUM(order_details.quantity * pizzas.price),0) AS TOTAL_REVENUE
from 
order_details
inner join
pizzas
on order_details.pizza_id = pizzas.pizza_id;

--Identify the highest-priced pizza.

SELECT MAX(price) AS MAX_PRICE_PIZZA FROM pizzas;

--Identify the most common pizza size ordered.

SELECT TOP 1 PA.size, COUNT(OD.order_details_id) AS order_count
FROM
pizzas as PA
join
order_details as OD
on PA.pizza_id=OD.pizza_id
GROUP BY PA.size
ORDER BY order_count DESC;

--List the top 5 most ordered pizza types along with their quantities.

SELECT TOP(5) PA.pizza_type_id,count(OD.quantity) as QUANTITY
from 
pizzas as PA
inner join
order_details as OD
on PA.pizza_id=OD.pizza_id
group by pizza_type_id
order by QUANTITY desc;


--INTERTMEDIATE--

--Join the necessary tables to find the total quantity of each pizza category ordered.

ALTER TABLE order_details ALTER COLUMN quantity Numeric(3);

SELECT PA.category,sum(OD.quantity) as TOTAL_QUANTITY
from
pizza_types as PA
join
pizzas as P
on PA.pizza_type_id=P.pizza_type_id
join
order_details as OD
on OD.pizza_id = P.pizza_id
group by PA.category
order by TOTAL_QUANTITY DESC;

--Determine the distribution of orders by hour of the day.

SELECT DATEPART(HOUR,time) AS order_hour, COUNT(order_id) AS order_count
FROM orders
GROUP BY DATEPART(HOUR,time)
ORDER BY order_count desc;

--Join relevant tables to find the 
--category-wise distribution of pizzas.

select category,count(name) as count
from
pizza_types
group by category;

--Group the orders by date and calculate the average number of pizzas ordered per day.

select avg(ord_perDay) as avg_value from (select orders.date,sum(order_details.quantity) as ord_perDay
from
orders
join
order_details
on orders.order_id=order_details.order_id
group by date) as order_quantity;

--Determine the top 3 most ordered pizza types based on revenue.

select Top 3 pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from
pizzas
join
pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join
order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name
order by revenue desc;

--Advance

--Analyze the cumulative revenue generated over time.

SELECT date,
SUM(revenue) over(order by date) as cumulative_revenue
from
(select orders.date, 
sum(order_details.quantity * pizzas.price) as revenue
from
order_details
join
pizzas
on order_details.pizza_id = pizzas.pizza_id
join
orders
on orders.order_id = order_details.order_id
group by orders.date) AS SALES;

--Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name,revenue
from
(select category,name,revenue,
RANK() over(partition by category order by revenue desc) AS RN
from
(select  name,category,
sum(order_details.quantity * pizzas.price) as revenue
from
order_details
join
pizzas
on order_details.pizza_id=pizzas.pizza_id
join
pizza_types
on pizza_types.pizza_type_id=pizzas.pizza_type_id
group by name,category) as A) AS B
where RN<=3;

--Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,
round(((sum(order_details.quantity * pizzas.price) / (select ROUND(SUM(order_details.quantity * pizzas.price),0) AS TOTAL_REVENUE
from 
order_details
inner join
pizzas
on order_details.pizza_id = pizzas.pizza_id)) *100),2) as Total_rev
from
order_details
join
pizzas
on order_details.pizza_id=pizzas.pizza_id
join
pizza_types
on pizza_types.pizza_type_id=pizzas.pizza_type_id
group by pizza_types.category
order by Total_rev desc
;