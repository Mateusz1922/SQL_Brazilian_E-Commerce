-- zadania cd

-- 1. self join
-- jakie 2 różne produkty klienci najczęściej wrzucają do jednego zamówienia
select 
	oi1.product_id as product_a,
	oi2.product_id as product_b,
	count(*) as times_bought_together
from order_items oi1
join order_items oi2 on oi1.order_id = oi2.order_id
where oi1.product_id < oi2.product_id
group by 1, 2
order by times_bought_together desc
limit 10;

-- where oi1.product_id < oi2.product_id - wyjaśnienie
-- Gdyby dać <>, baza połączyłaby produkt A z produktem A 
-- (sparowałaby go ze samym sobą). Ponadto, policzyłaby parę 
-- (Produkt A, Produkt B) oraz (Produkt B, Produkt A) jako dwa 
-- osobne zdarzenia. Znak mniejszości < eliminuje duplikaty 
-- i parowanie samego ze sobą za jednym zamachem.

-- 2. lag/lead
-- lag - spojrzenie w przeszłość
-- lead - przyszłość
-- wyliczenie wzrostu miesiąc w miesiąc

with monthly_revenue as (
	select
		DATE_TRUNC('month', o.order_purchase_timestamp) AS sale_month,
		sum(oi.price) as current_month_revenue
	from orders o
	join order_items oi on oi.order_id = o.order_id 
	where o.order_status = 'delivered'
	group by sale_month
)
select 
	sale_month,
	round(current_month_revenue::numeric, 2) as current_revenue,
	
	-- LAG pobiera przychód z wiersza wyżej (poprzedni miesiąc)
	round((lag(current_month_revenue, 1) over (order by sale_month))::numeric, 2) as previous_revenue,
	
	-- LEAD pobiera przychód z wiersza poniżej (następny miesiąc)
	round((lead(current_month_revenue, 1) over (order by sale_month))::numeric, 2) as next_revenue,
	
	-- Obliczenie różnicy kwotowej miesiąc do miesiąca
	round((current_month_revenue - lag(current_month_revenue, 1) over (order by sale_month))::numeric, 2) as mom_delta_value
from monthly_revenue
order by sale_month;


	