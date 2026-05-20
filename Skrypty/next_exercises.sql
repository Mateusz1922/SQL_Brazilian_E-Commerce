-- 1.  Wyświetl ID produktu, jego kategorię oraz cenę, a w nowej kolumnie najwyższą (maksymalną) cenę, jaka występuje w całej jego kategorii.
select 
	p.product_id, 
	p.product_category_name, 
	oi.price,
	max(oi.price) over(partition by p.product_category_name) as max_category_price
from products p
join order_items oi on oi.product_id = p.product_id
order by oi.price desc;

-- 2. Dla każdego przedmiotu w zamówieniu wyświetl order_id, product_id, jego koszty transportu (freight_value) oraz to, 
--    jaki procent wszystkich kosztów transportu tego zamówienia stanowi ten konkretny przedmiot.
select 
	oi.order_id,
	oi.product_id,
	oi.freight_value,
	oi.freight_value / sum(oi.freight_value) over(partition by oi.order_id) * 100 as percent_of_total_transport
from order_items oi
where oi.freight_value > 0;

-- 3. Ponumeruj zamówienia każdego unikalnego klienta (customer_unique_id) od najstarszego do najnowszego. Wyświetl tylko te, które dostały numerek 1.
with client_chrono_orders as (
	select
		o.order_id,
		c.customer_unique_id,
		o.order_purchase_timestamp,
		row_number() over(partition by c.customer_unique_id order by o.order_purchase_timestamp asc) as order_sequence
	from customers c
	join orders o on c.customer_id = o.customer_id
)
select *
from client_chrono_orders 
where order_sequence = 1;

-- 4. Wyświetl wszystkich klientów z tabeli customers, którzy nie mają ani jednego powiązanego wpisu w tabeli orders, używając mechanizmu NOT EXISTS.
select *
from customers c
where not exists (
	select 1
	from orders o
	where c.customer_id = o.customer_id
);

-- 5. Wyświetl listę produktów z tabeli products, które nigdy nie pojawiły się w tabeli order_items. Ponownie użyj NOT EXISTS.
select p.product_id
from products p
where not exists (
	select 1
	from order_items oi
	where oi.product_id = p.product_id
);

-- 6. Dla każdego sprzedawcy wyświetl jego seller_id, stan oraz kolumnę informującą, ile unikalnych produktów ten sprzedawca ma w swojej ofercie.
select distinct
	oi.seller_id,
	count(product_id) over(partition by oi.seller_id) as total_distinct_products_sold
from order_items oi

-- 7. Dla każdego unikalnego klienta wyświetl datę jego zamówienia oraz w sąsiedniej kolumnie datę jego kolejnego (następnego) zamówienia.
select
	c.customer_unique_id,
	o.order_purchase_timestamp,
	lead(o.order_purchase_timestamp) over(partition by c.customer_unique_id order by o.order_purchase_timestamp asc) as next_order_date
from customers c
join orders o on o.customer_id = c.customer_id
order by c.customer_unique_id, o.order_purchase_timestamp;

