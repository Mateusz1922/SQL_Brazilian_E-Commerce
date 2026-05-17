-- Sprawdźmy, które kategorie produktów generują największy przychód
--SELECT 
--    p.product_category_name,
--    ROUND(SUM(oi.price), 2) AS total_revenue,
--    COUNT(oi.order_id) AS items_sold
--FROM order_items oi
--JOIN products p ON oi.product_id = p.product_id
--GROUP BY 1 -- grupowanie po pierwszej kolumnie z listy
--ORDER BY total_revenue DESC
--LIMIT 10;

-- czy mamy duplikaty zamówień?
--select order_id, count(*)
--from orders
--group by order_id
--having count(*) > 1;
-- nie mamy

-- Ile mamy brakujacych wartosci null w kluczowych kolumnach? np. czy dane dostarczone do klienta
--select count(*) - count(order_delivered_customer_date) as missing_delivery_dates
--from orders;
-- 2965 - nie wszystko dostarczone

-- sprawdzam zakres dat
--select min(order_purchase_timestamp), max(order_purchase_timestamp)
--from orders
-- 4.9.2016 21:15 - 17.10.2018 17:30

-- sprawdzam czy nowy plik zostal dodany
--SELECT 
--    payment_type, 
--    COUNT(*) as number_of_transactions,
--    SUM(payment_value) as total_collected
--FROM order_payments
--GROUP BY payment_type
--ORDER BY total_collected DESC;

-- przychód z poprzedniego miesiąca i różnica month-to-month
--WITH monthly_sales AS (
--    SELECT 
--        DATE_TRUNC('month', o.order_purchase_timestamp) AS sale_month,
--        SUM(oi.price) AS total_revenue
--    FROM orders o
--    JOIN order_items oi ON o.order_id = oi.order_id
--    WHERE o.order_status = 'delivered'
--    GROUP BY 1
--)
--SELECT 
--    sale_month,
--    total_revenue,
--    LAG(total_revenue) OVER (ORDER BY sale_month) AS prev_month_revenue,
--    ROUND(((total_revenue - LAG(total_revenue) OVER (ORDER BY sale_month)) / LAG(total_revenue) OVER (ORDER BY sale_month) * 100), 2) AS pct_growth
--FROM monthly_sales;
--
--SELECT DATE_TRUNC('month', NOW());
--SELECT DATE_TRUNC('month', '2026-01-15'::timestamp);

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
--select p.product_category_name, ROUND(avg(oi.price), 2) as avg_price
--from order_items oi
--join products p on p.product_id = oi.product_id
--group by p.product_category_name
--having avg(oi.price) > 150
--order by avg(oi.price) desc

-- 4. 10 sprzedawcow najwiecej za sam transport bez canceled
--select oi.seller_id, sum(oi.freight_value) as total_freight_revenue
--from order_items oi
--join orders o on oi.order_id = o.order_id
--where o.order_status <> 'canceled'
--group by oi.seller_id
--order by total_freight_revenue desc
--limit 10;

-- 5. dla delivered oblicz średni czas oczekiwania klienta (różnica purchased i delivered.) 
-- wynik w dniach i pogrupuj według lokalizacji stanu klienta
--select c.customer_state, round(avg(extract(day from (o.order_delivered_customer_date - o.order_purchase_timestamp))), 2) as avg_waiting_time
--from orders o
--join customers c on c.customer_id = o.customer_id
--where o.order_status = 'delivered' and o.order_delivered_customer_date is not null
--group by c.customer_state
--order by avg_waiting_time asc;

-- 6. lista kategorii produktow, ktore sa w products ale nigdy nie zostały zamówione
--select p.product_category_name
--from products p
--left join order_items oi on p.product_id = oi.product_id
--where oi.order_id is null and p.product_category_name is not null

-- alternatywa
--SELECT product_category_name FROM products
--EXCEPT
--SELECT p.product_category_name 
--FROM products p 
--JOIN order_items oi ON p.product_id = oi.product_id;
