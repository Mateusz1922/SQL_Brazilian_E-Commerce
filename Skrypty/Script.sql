-- funkcje okna
-- 1. top 3 najdrozszych dla kazdej kategorii
with ranked_products as (
	select
		p.product_category_name,
		p.product_id,
		oi.price,
		dense_rank() over(partition by p.product_category_name order by oi.price desc) as price_rank
	from products p
	join order_items oi on oi.product_id = p.product_id
	where product_category_name is not null and p.product_category_name <> ''
)
select *
from ranked_products
where price_rank <= 3
order by product_category_name, price_rank;

-- 2. jak rośnie przychód firmy dzień po dniu w 2017 r.
with daily_revenue as (
	select
		o.order_purchase_timestamp::date AS sale_date,
		sum(oi.price + oi.freight_value) as daily_total
	from orders o
	join order_items oi on oi.order_id = o.order_id 
	where o.order_status = 'delivered' and o.order_purchase_timestamp between '2017-01-01' and '2017-12-31'
	group by 1
)
select 
	sale_date,
	round(daily_total, 2),
	round(sum(daily_total) over(order by sale_date), 2) -- bez order by mamy wszedzie tę samą sumę
from daily_revenue
order by sale_date

-- 3. klienci > 1 order, wartosc tego i poprzedniego zamowienia
with customer_orders as (
	select 
		c.customer_unique_id,
		o.order_purchase_timestamp,
		sum(f.order_total_value) as order_value
	from view_fact_sales f
	join orders o on o.order_id = f.order_id 
	join customers c on o.customer_id = c.customer_id 
	group by 1, 2
)
select
	customer_unique_id,
	order_purchase_timestamp,
	round(order_value::numeric, 2) as current_order_value,
	round(lag(order_value) over(partition by customer_unique_id order by order_purchase_timestamp)::numeric, 2) as prev_order_value
from customer_orders
order by customer_unique_id, order_purchase_timestamp;

-- 4. identyfikacja produktów nienaturalnie drogich w swoich kategoriach
with product_prices as (
	select distinct 
		p.product_id,
		p.product_category_name,
		oi.price,
		avg(oi.price) over(partition by p.product_category_name) as avg_category_price
	from order_items oi
	join products p on p.product_id = oi.product_id 
	where p.product_category_name is not null and p.product_category_name <> ''
)
select
	product_id,
	product_category_name,
	round(price::numeric, 2) as product_price,
	round(avg_category_price::numeric, 2) as category_avg,
	round(((price - avg_category_price) / avg_category_price * 100)::numeric, 2) as pct_deviation
from product_prices
order by pct_deviation desc
limit 15;

-- 5. wygładzony trend przychodów sprzedawców, średnia krocząca z 3 ostatnich zamówień
 select 
 	seller_id,
 	order_id,
 	price as current_item_price,
 	round(
 		avg(price) over(
 			partition by seller_id 
 			order by shipping_limit_date 
 			rows between 2 preceding and current row
 			)::numeric, 2) as moving_avg_3_items
 from order_items
 order by seller_id, shipping_limit_date 
 limit 20;






