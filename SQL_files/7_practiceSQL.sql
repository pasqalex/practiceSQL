WITH all_canceled_orders AS (
    SELECT order_id
    FROM user_actions
    WHERE action = 'cancel_order'
),
all_not_canceled_orders AS (
    SELECT order_id
    FROM user_actions ua
    WHERE NOT EXISTS (SELECT 1 FROM all_canceled_orders aco
                            WHERE aco.order_id = ua.order_id)
),
top_expensive_products AS (
    SELECT product_id
    FROM products
    ORDER BY price DESC
    LIMIT 5
),
expanded_orders AS (
    SELECT
        order_id,
        UNNEST(o.product_ids) AS product_id
    FROM orders o
    WHERE EXISTS (SELECT 1 FROM all_not_canceled_orders anc
                        WHERE anc.order_id = o.order_id
    )
),
orders_with_expensive_products AS (
    SELECT order_id, product_id
    FROM expanded_orders eo
    WHERE EXISTS (SELECT 1 FROM top_expensive_products tep 
                        WHERE tep.product_id = eo.product_id))
SELECT
    order_id,
    product_ids
FROM orders o
WHERE EXISTS (SELECT 1 FROM orders_with_expensive_products owep
                    WHERE owep.order_id = o.order_id)
ORDER BY order_id
