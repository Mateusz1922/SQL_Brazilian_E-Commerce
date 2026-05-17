-- 1. top 5 miast z najwieksza liczba klientow
--select c.customer_city, count(c.customer_id) as customer_count
--from customers c
--group by c.customer_city
--order by customer_count desc
--limit 5

-- 2. finanse i raty - wszystkie unikalne zamowienia oplacone w wiecej niz 10 ratach
--select op.order_id, op.payment_installments 
--from order_payments op
--where op.payment_installments > 10
--order by op.payment_installments desc

-- 3. srednia cena produktu dla kazdej kategorii
select p.product_category_name, avg(oi.price)
from order_items oi
join products p on p.product_id = oi.product_id
group by p.product_category_name
having avg(oi.price) > 150
order by avg(oi.price) desc


