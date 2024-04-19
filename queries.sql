--Применяем агрегацию по id, чтобы посчитать количество покупателей.
select count(customer_id) as customers_count
from customers c