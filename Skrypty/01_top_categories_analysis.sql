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
-- 0 - wszystko dostarczone

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
--    (total_revenue - LAG(total_revenue) OVER (ORDER BY sale_month)) / LAG(total_revenue) OVER (ORDER BY sale_month) * 100 AS pct_growth
--FROM monthly_sales;
--
--SELECT DATE_TRUNC('month', NOW());
--SELECT DATE_TRUNC('month', '2026-01-15'::timestamp);




