-- fact table view
create or replace view view_fact_sales as 
select
	oi.order_id,
	oi.product_id,
	o.customer_id,
	p.product_category_name,
	-- wartość zamówienia (cena + transport)
	(oi.price + oi.freight_value) as order_total_value,
	-- czas dostawy w dniach
	(o.order_delivered_customer_date::date - o.order_purchase_timestamp::date) as delivery_time_days
from order_items oi
join orders o on o.order_id = oi.order_id
left join products p on oi.product_id = p.product_id

-- 10 pierwszych rekordów z naszej gotowej tabeli faktów
SELECT * 
FROM view_fact_sales 
LIMIT 10;

-- Które kategorie produktów docierają do klientów najszybciej, a które najwolniej?
select 
	product_category_name,
	round(avg(delivery_time_days), 1) as avg_delivery_days,
	count(distinct order_id) as total_orders
from view_fact_sales
where delivery_time_days is not null
group by product_category_name 
order by avg_delivery_days desc