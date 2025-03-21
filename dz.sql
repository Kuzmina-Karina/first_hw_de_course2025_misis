--1
SELECT 
    c.name AS category_name,
    ROUND(AVG(p.price * oi.quantity), 2) AS avg_order_amount
FROM orders ord
    left JOIN order_items oi ON ord.id = oi.order_id
    left JOIN products p ON oi.product_id = p.id
    left JOIN categories c ON p.category_id = c.id
WHERE  ord.created_at >= '2023-03-01' AND ord.created_at < '2023-04-01'
GROUP BY c.name;


--2
SELECT  us.name AS user_name,
        SUM(pay.amount) AS total_spent,
        RANK() OVER (ORDER BY sum(pay.amount) DESC) as user_rank
FROM users us
    left JOIN orders ord ON us.id = ord.user_id
    left JOIN payments pay ON ord.id = pay.order_id
WHERE  ord.status = 'Оплачен'
GROUP BY  us.name
limit 3


-- 3
SELECT 
    TO_CHAR(ord.created_at, 'YYYY-MM') AS month,
    COUNT(ord.id) AS total_orders,
    COALESCE(SUM(pay.amount), 0) AS total_payments
FROM orders ord
    LEFT JOIN payments pay ON ord.id = pay.order_id
WHERE ord.created_at >= '2023-01-01' AND ord.created_at < '2024-01-01'
GROUP BY TO_CHAR(ord.created_at, 'YYYY-MM')
ORDER BY month;


--4
SELECT 
    p.name as product_name,
    sum(oi.quantity) as total_sold,
    round(sum(oi.quantity)*100.0/(select sum(temp_oi.quantity) from order_items temp_oi), 2) as sales_percantage
FROM products p
    LEFT JOIN order_items oi ON oi.product_id = p.id
GROUP BY p.name
order by total_sold DESC
limit 5


--5 
WITH temp AS (
    SELECT 
        us.name as name,
        round(COALESCE(sum(pay.amount), 0), 2) as coins
    FROM users us
        left JOIN orders ord ON us.id = ord.user_id
        left JOIN payments pay ON ord.id = pay.order_id
    where ord.status='Оплачен'
    GROUP BY us.name
)
select  
    temp.name,
    temp.coins
from temp 
where (select avg(coins) from temp) < temp.coins



--6
with temp as(
    SELECT 
        RANK() OVER (PARTITION BY c.name ORDER BY SUM(oi.quantity) DESC) AS sales_rank,
        c.name AS category_name,
        p.name AS product_name,
        SUM(oi.quantity) AS total_sold
    FROM products p
        JOIN order_items oi ON p.id = oi.product_id
        JOIN categories c ON p.category_id = c.id
    GROUP BY  c.name, p.name
    ORDER BY  category_name, sales_rank
)
SELECT 
    category_name,
    product_name,
    total_sold
FROM temp
WHERE sales_rank <= 3


--7
WITH temp AS (
    SELECT 
        TO_CHAR(ord.created_at, 'YYYY-MM') AS month,
        c.name AS category_name,
        SUM(p.price * oi.quantity) AS total_revenue,
        RANK() OVER (PARTITION BY TO_CHAR(ord.created_at, 'YYYY-MM') ORDER BY SUM(p.price * oi.quantity) DESC) AS revenue_rank
    FROM orders ord
        JOIN order_items oi ON ord.id = oi.order_id
        JOIN products p ON oi.product_id = p.id
        JOIN categories c ON p.category_id = c.id
    WHERE ord.created_at >= '2023-01-01' AND ord.created_at < '2023-07-01'
    GROUP BY TO_CHAR(ord.created_at, 'YYYY-MM'), c.name
)
SELECT 
    month,
    category_name,
    total_revenue
FROM temp
WHERE revenue_rank = 1
ORDER BY month;



--8
WITH temp AS (
    SELECT 
        TO_CHAR(pay.payment_date, 'YYYY-MM') AS month,
        SUM(pay.amount) AS monthly_payments
    FROM payments pay
    WHERE pay.payment_date >= '2023-01-01' AND pay.payment_date < '2024-01-01'
    GROUP BY TO_CHAR(pay.payment_date, 'YYYY-MM')
)
SELECT 
    month,
    monthly_payments,
    SUM(monthly_payments) OVER (ORDER BY month) AS cumulative_payments
FROM 
    temp
ORDER BY 
    month;
