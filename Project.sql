drop table df_orders;

select * from df_orders;


--find top 10 highest revenue generating products
select product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc
limit 10

--find top 5 highest selling products in each region
with highest_selling as (
select region,product_id, sum(sale_price) as total
from df_orders
group by 1,2
)
select * from (
select * ,row_number() over(partition by region order by total desc) rn
from highest_selling) sub
where rn<6
order by region ,total desc;


--find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
with cte as (
select extract(month from order_date) as mon, extract(year from order_date) as yr, sum(sale_price) as total_sale
from df_orders
group by 1,2)

select mon,
sum(case when yr = '2022' then total_sale else 0 end )as sales_2022,
sum(case when yr = '2023' then total_sale else 0 end )as sales_2023
from cte
group by mon
ORDER BY MON

--for each category which month has highest sales
select category,sale_mon,total_sale
from(
select category, to_char(order_date, 'mon-yyyy') as sale_mon, sum(sale_price) as total_sale,
row_number() over(partition by category order by sum(sale_price)desc ) as rn
from df_orders
group by 1,2) sub
where rn =1
