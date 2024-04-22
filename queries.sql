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
