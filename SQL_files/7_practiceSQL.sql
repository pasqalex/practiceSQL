with top_expensive_products as (
SELECT product_id
FROM products
order by price desc
limit 5
),
expanded_orders AS (
    SELECT
        o.order_id,
        UNNEST(o.product_ids) AS product_id
    FROM orders o
),
orders_with_expensive_products as (
SELECT order_id, product_id
FROM expanded_orders eo
WHERE exists (select 1 from top_expensive_products tep 
                    where tep.product_id = eo.product_id)
)
SELECT
    order_id,
    product_ids
FROM
    orders o
WHERE exists (select 1 from orders_with_expensive_products owep
                    where owep.order_id = o.order_id)
order by order_id
