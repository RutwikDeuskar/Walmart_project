select * from wallmart

/* Business Problems */
---1. Analyze Payment Methods and Sales

--Total sales by each method

select
	payment_method,
	sum("total price") as Sales
	
from wallmart
group by 1

/* Question: What are the different payment methods, and how many transactions and
items were sold with each method? */

select
	payment_method,
	sum(quantity) as Net_Quantity,
	count(*) as Transactions
from wallmart
group by 1

/* 2. Identify the Highest-Rated Category in Each Branch */

select *
from
(select
	branch,
	category,
	avg(rating),
	rank()over(partition by branch order by avg(rating)desc)
from wallmart
group by 1,2)
where rank = 1

/* 3. Determine the Busiest Day for Each Branch based on trasaction volume*/

select *
from
(select
	branch,
	to_char(to_date(date,'dd/mm/yy'),'Day') as Day_Name,
	count(*) as Transactions,
	rank()over(partition by branch order by count(*)desc)as rank
from wallmart
group by 1,2)
where rank=1

/* 4. Calculate Total Quantity Sold by Payment Method */

select
	payment_method,
	sum(quantity)as Total_Quantity
from wallmart
group by payment_method

/* 5. Question: What are the average, minimum, and maximum ratings for each category in
each city? */


select
	city,
	category,
	min(rating),
	max(rating),
	avg(rating)
from wallmart
group by 1,2

/* 6. Calculate Total Profit by Category */

select
	category,
	sum("total price"*profit_margin) as profit
from wallmart
group by 1
order by profit desc

/* 7 Question: What is the most frequently used payment method in each branch? */

with cte
as

(select
	branch,
	payment_method,
	count(*) as transactions,
	rank()over(partition by branch order by count(*) desc)as rank
from wallmart
group by 1,2
)
select *
from cte
where rank =1;

/* 8 Question: How many transactions occur in each shift (Morning, Afternoon, Evening)
across branches? */

select
	branch,
	count(*) as Transactions,
	case
		when extract(hour from(time::time)) < 12 then 'Morning'
		when extract(hour from(time::time)) between 12 and 17 then 'Afternoon'
		else 'Evening'
	end Day_Time
from wallmart
group by 1,3
order by 1,2 desc

/* 9 Question: Which branches experienced the largest decrease in revenue compared to
the previous year? */
---Identify Branches with Highest Revenue Decline Year-Over-Year


with revenue_2022
as
(select
	branch,
	---to_char(to_date(date,'dd/mm/yy'),'yyyy') as Year,
	sum("total price") as revenue
from wallmart
where EXTRACT(YEAR FROM to_date(date,'dd/mm/yy')) =2022
group by 1),
revenue_2023
as
(select
	branch,
	---to_char(to_date(date,'dd/mm/yy'),'yyyy') as Year,
	sum("total price") as revenue
from wallmart
where EXTRACT(YEAR FROM to_date(date,'dd/mm/yy')) =2023	
group by 1)
select
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cs_year_revenue,
	ROUND((
	(cs.revenue/ls.revenue)-1)::NUMERIC
	*-100,2) as decrease_percentage
from revenue_2022 as ls
join revenue_2023 as cs
on ls.branch=cs.branch
where ls.revenue>cs.revenue
ORDER BY 4 DESC
LIMIT 5