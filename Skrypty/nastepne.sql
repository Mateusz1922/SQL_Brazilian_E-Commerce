-- 1. Wyświetl listę stanów klientów (customer_state) wraz ze średnią liczbą dni, jaka upływa między wysłaniem paczki przez sprzedawcę (order_delivered_carrier_date) 
--    a jej fizycznym odebraniem przez klienta (order_delivered_customer_date). Wynik posortuj od stanu z najdłuższym czasem oczekiwania.

with average_days as (
select 
	c.customer_state,
	avg(extract(day from (o.order_delivered_customer_date - o.order_delivered_carrier_date) ))
		over(
			partition by c.customer_state) as average_time_state
from customers c
join orders o on o.customer_id = c.customer_id
)
select 
	customer_state,
	average_time_state
from average_days
group by customer_state, average_time_state
order by average_time_state desc;

SELECT 
    c.customer_state,
    ROUND(AVG(o.order_delivered_customer_date::date - o.order_delivered_carrier_date::date), 1) AS avg_carrier_to_customer_days,
    COUNT(o.order_id) AS total_delivered_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL 
  AND o.order_delivered_carrier_date IS NOT NULL
GROUP BY 1
ORDER BY avg_carrier_to_customer_days DESC;

-- 2. Dla każdej kategorii produktów oblicz, ile zamówień dotarło po terminie (czyli data dostawy do klienta była późniejsza niż 
--   data szacowana przez system). Pokaż tylko te kategorie, które zaliczyły w sumie ponad 50 takich spóźnionych zamówień.

select 
	p.product_category_name,
	count(oi.order_id)
from products p
join order_items oi on p.product_id = oi.product_id
join orders o on oi.order_id = o.order_id 
where o.order_estimated_delivery_date < o.order_delivered_customer_date 
	and p.product_category_name <> ''
group by p.product_category_name 
having count(oi.order_id) > 50
order by count(oi.order_id) desc;

-- 3. Znajdź 5% najwyższych pod względem wartości zamówień w całej bazie. Dla tej elitarnej grupy zamówień zlicz, 
--    ile razy użyto poszczególnych typów płatności (payment_type).

with order_values as (
	select
		op.order_id,
		sum(op.payment_value) as total_value,
		percent_rank() over(order by sum(op.payment_value) desc) as p_rank
	from order_payments op
	group by op.order_id
	)
select
	op.payment_type,
	count(distinct op.order_id) as order_count
from order_payments op
join order_values ov on op.order_id = ov.order_id 
where ov.p_rank <= 0.05
group by 1
order by order_count desc;

-- 4. Wyciągnij listę unikalnych produktów (product_id), które były kupowane przez klientów 
--    w ich absolutnie pierwszym zamówieniu w życiu na tej platformie.

WITH customer_journey AS (
    SELECT 
        c.customer_unique_id,
        oi.product_id,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id 
            ORDER BY o.order_purchase_timestamp ASC
        ) AS order_seq
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN customers c ON o.customer_id = c.customer_id
)
SELECT DISTINCT 
    count(product_id)
FROM customer_journey
WHERE order_seq = 1;

-- 5. Dla każdego zamówienia oblicz, jaki procent łącznej kwoty (cena towaru + transport) stanowił sam koszt transportu. 
-- Wyświetl zamówienia, w których dostawa kosztowała więcej niż sam produkt, pokazując ID zamówienia, cenę produktu i koszt wysyłki.

SELECT 
    order_id,
    price,
    freight_value,
    ROUND((freight_value / (price + freight_value) * 100)::numeric, 2) AS freight_share_pct
FROM order_items
WHERE freight_value > price
ORDER BY freight_share_pct DESC;

-- 6. Wyświetl listę wszystkich danych (ID, miasto, stan) tych sprzedawców z tabeli sellers, 
--    którzy nie posiadają żadnej historii sprzedaży w tabeli transakcyjnej.

SELECT 
    s.seller_id,
    s.seller_city,
    s.seller_state
FROM sellers s
WHERE NOT EXISTS (
    SELECT 1 
    FROM order_items oi 
    WHERE oi.seller_id = s.seller_id
);

-- 7. Dla każdego miesiąca w bazie (użyj daty zakupu) oblicz całkowity przychód ze sprzedaży produktów. 
--    W kolumnie obok wyświetl przychód z poprzedniego miesiąca, a w trzeciej kolumnie różnicę kwotową (obecny miesiąc minus poprzedni).

WITH monthly_sales AS (
    SELECT 
        TO_CHAR(order_purchase_timestamp, 'YYYY-MM') AS sales_month,
        SUM(price) AS total_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE order_status = 'delivered'
    GROUP BY 1
)
SELECT 
    sales_month,
    ROUND(total_revenue::numeric, 2) AS current_month_revenue,
    ROUND(
        LAG(total_revenue) OVER (ORDER BY sales_month)::numeric, 
        2
    ) AS previous_month_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY sales_month))::numeric, 
        2
    ) AS month_over_month_diff
FROM monthly_sales
ORDER BY sales_month;

-- 8. Wyświetl każde sprzedane zamówienie. Pokaż ID sprzedawcy, datę sprzedaży oraz cenę przedmiotu. 
--    W sąsiedniej kolumnie wyświetl średnią cenę wszystkich produktów sprzedanych przez tego konkretnego sprzedawcę, 
--    aby móc natychmiast porównać, czy ta konkretna transakcja była powyżej, czy poniżej jego standardu.

SELECT 
    oi.seller_id,
    o.order_purchase_timestamp,
    oi.order_id,
    oi.price AS item_price,
    ROUND(
        AVG(oi.price) OVER (PARTITION BY oi.seller_id)::numeric, 
        2
    ) AS seller_overall_avg_price
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
ORDER BY oi.seller_id, o.order_purchase_timestamp;
