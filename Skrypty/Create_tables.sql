-- 1. Create client table
--CREATE TABLE customers (
--	customer_id UUID PRIMARY KEY,
--	customer_unique_id UUID,
--	customer_zip_code_prefix INT,
--	customer_city VARCHAR(100),
--	customer_state CHAR(2)
--);

-- 2. Create product table
--CREATE TABLE products (
--	product_id UUID PRIMARY KEY,
--	product_category_name VARCHAR(100),
--	product_name_lenght INT,
--	product_description_lenght INT,
--    product_photos_qty INT,
--    product_weight_g INT,
--    product_length_cm INT,
--    product_height_cm INT,
--    product_width_cm INT
--);

-- 3. Create orders table
--CREATE TABLE orders (
--    order_id UUID PRIMARY KEY,
--    customer_id UUID REFERENCES customers(customer_id),
--    order_status VARCHAR(20),
--    order_purchase_timestamp TIMESTAMP,
--    order_approved_at TIMESTAMP,
--    order_delivered_carrier_date TIMESTAMP,
--    order_delivered_customer_date TIMESTAMP,
--    order_estimated_delivery_date TIMESTAMP
--);

-- 4. Create table order position 
--CREATE TABLE order_items (
--    order_id UUID REFERENCES orders(order_id),
--    order_item_id INT,
--    product_id UUID REFERENCES products(product_id),
--    seller_id UUID,
--    shipping_limit_date TIMESTAMP,
--    price DECIMAL(10, 2),
--    freight_value DECIMAL(10, 2),
--    PRIMARY KEY (order_id, order_item_id)
--);

-- 5. Create order payments table
CREATE TABLE order_payments (
    order_id UUID REFERENCES orders(order_id),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value DECIMAL(10, 2),
    PRIMARY KEY (order_id, payment_sequential)
);

--COPY customers FROM 'C:/Users/Mateusz/Documents/Projekty/data_Brazilian/olist_customers_dataset.csv' DELIMITER ',' CSV HEADER;
--COPY products FROM 'C:/Users/Mateusz/Documents/Projekty/data_Brazilian/olist_products_dataset.csv' DELIMITER ',' CSV HEADER;
--COPY orders FROM 'C:/Users/Mateusz/Documents/Projekty/data_Brazilian/olist_orders_dataset.csv' DELIMITER ',' CSV HEADER;
--COPY order_items FROM 'C:/Users/Mateusz/Documents/Projekty/data_Brazilian/olist_order_items_dataset.csv' DELIMITER ',' CSV HEADER;
--COPY order_payments FROM 'C:/Users/Mateusz/Documents/Projekty/data_Brazilian/olist_order_payments_dataset.csv' DELIMITER ',' CSV HEADER;

