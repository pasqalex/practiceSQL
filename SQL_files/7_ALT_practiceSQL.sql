WITH top_expensive_products AS (
    SELECT product_id
    FROM products
    ORDER BY price DESC
    LIMIT 5)
SELECT
    o.order_id,
    o.product_ids
FROM orders o
WHERE EXISTS (
    SELECT 1 FROM top_expensive_products tep WHERE tep.product_id = ANY(o.product_ids))
ORDER BY o.order_id
