--Применяем агрегацию по id, чтобы посчитать количество покупателей.
select count(customer_id) as customers_count
from customers;

--Соединяем нужные таблицы, считаем количество операций и общую
--выручку 10 лучших продавцов.
select
    e.first_name || ' ' || e.last_name as seller,
    count(s.sales_person_id) as operations,
    floor(sum(s.quantity * p.price)) as income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on s.product_id = p.product_id
group by seller
order by income desc
limit 10;

--Высчитываем среднюю выручку продавцов и отсекаем тех у кого больше среднего
--через having и подзапрос.
select
    e.first_name || ' ' || e.last_name as seller,
    floor(avg(s.quantity * p.price)) as average_income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on s.product_id = p.product_id
group by seller
having
    avg(s.quantity * p.price)
    < (
        select avg(s.quantity * p.price)
        from sales
        inner join products on sales.product_id = products.product_id
    )
order by average_income;

--Разграничиваем общую выручку продавцов по дням недели и сортируем
--в правильном порядке.
select
    e.first_name || ' ' || e.last_name as seller,
    to_char(s.sale_date, 'day') as day_of_week,
    floor(sum(s.quantity * p.price)) as income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on s.product_id = p.product_id
group by seller, day_of_week, to_char(s.sale_date, 'ID')
order by to_char(s.sale_date, 'ID'), seller;

--Через подзапрос группируем возраст на категории и считаем количество
--в каждой категории.
with tab as (
    select
        case
            when age between 16 and 25 then '16-25'
            when age between 26 and 40 then '26-40'
            else '40+'
        end as age_category
    from customers
)

select
    age_category,
    count(age_category) as age_count
from tab
group by age_category
order by age_category;

--Через подзапрос группируем по месяцам, добавляя необходимые столбцы.
--Соединяем таблицы и высчитываем уникальных покупателей и выручку за месяц.
with tab as (
    select
        customer_id,
        product_id,
        quantity,
        to_char(sale_date, 'YYYY-MM') as selling_month
    from sales
)

select
    t.selling_month,
    count(distinct t.customer_id) as total_customers,
    floor(sum(t.quantity * p.price)) as income
from tab as t
inner join products as p on t.product_id = p.product_id
group by t.selling_month
order by t.selling_month;

--Выявляем дату первой покупки каждого покупателя. (Здесь результат
--неоднозначный, так как даны только даты, а покупки они совершают по много раз
--за день и не факт, что первая была с товаром по акции).
with tab as (
    select
        customer_id,
        min(sale_date) as first_date
    from sales
    group by customer_id
),

--Соединяем таблицы и отфильтровываем нужные строки.
tab2 as (
    select distinct
        s.customer_id,
        s.sale_date,
        c.first_name || ' ' || c.last_name as customer,
        e.first_name || ' ' || e.last_name as seller
    from sales as s
    inner join tab as t on s.customer_id = t.customer_id
    inner join products as p on s.product_id = p.product_id
    inner join customers as c on s.customer_id = c.customer_id
    inner join employees as e on s.sales_person_id = e.employee_id
    where t.first_date = s.sale_date and p.price = 0
)

select
    customer,
    sale_date,
    seller
from tab2
order by customer_id; --Вроде как distinct уже отсортировал id, но думаю
--лишним не будет, так как по условию требуется.
