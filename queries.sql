--Применяем агрегацию по id, чтобы посчитать количество покупателей.
select count(customer_id) as customers_count
from customers c

--Соединяем нужные таблицы, считаем количество операций и общую выручку 10 лучших продавцов.
select first_name || ' ' || last_name as seller, count(sales_person_id) as operations, floor(sum(quantity * price)) as income
from employees e 
join sales s on e.employee_id = s.sales_person_id
join products p on s.product_id = p.product_id
group by seller
order by income desc
limit 10

--Высчитываем среднюю выручку продавцов и отсекаем тех у кого больше среднего через having и подзапрос.
select first_name || ' ' || last_name as seller, floor(avg(quantity * price)) as average_income
from employees e
join sales s on e.employee_id = s.sales_person_id
join products p on s.product_id = p.product_id
group by seller
having avg(quantity * price) < (select avg(quantity * price) from sales join products on sales.product_id = products.product_id)
order by average_income

--Разграничиваем общую выручку продавцов по дням недели и сортируем в правильном порядке.
select first_name || ' ' || last_name as seller, to_char(sale_date, 'day') as day_of_week, floor(sum(quantity * price)) as income
from employees e
join sales s on e.employee_id = s.sales_person_id
join products p on s.product_id = p.product_id
group by seller, day_of_week, to_char(sale_date, 'ID')
order by to_char(sale_date, 'ID'), seller

--Через подзапрос группируем возраст на категории и считаем количество в каждой категории.
with tab as (
	select case when age between 16 and 25 then '16-25' when age between 26 and 40 then '26-40' else '40+' end as age_category
	from customers
)
select age_category, count(age_category) as age_count
from tab
group by age_category
order by age_category
