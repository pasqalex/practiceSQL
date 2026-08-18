WITH all_not_canceled_orders as (
    SELECT
        ua.order_id,
        ua.user_id
    FROM user_actions ua
    WHERE NOT EXISTS (
        SELECT 1
        FROM user_actions ua2
        WHERE ua2.order_id = ua.order_id
          AND ua2.action = 'cancel_order'
    )
),
expand_orders as (
    SELECT
        o.order_id,
        ua.user_id,
        UNNEST(o.product_ids) as product_id
    FROM orders o
        JOIN all_not_canceled_orders ua on ua.order_id = o.order_id
),
order_prices as (
    SELECT
        user_id,
        order_id,
        sum(p.price) as order_price
    FROM expand_orders eo
        LEFT JOIN products p USING(product_id)
    GROUP BY user_id, order_id
),
order_stats as (
    SELECT
        op.user_id,
        count(op.order_id) as orders_count,
        sum(op.order_price) as sum_order_value,
        round(avg(op.order_price), 2) as avg_order_value,
        min(op.order_price) as min_order_value,
        max(op.order_price) as max_order_value
    FROM order_prices op
    GROUP BY op.user_id
),
product_stats as (
    SELECT
        user_id,
        count(product_id) as products_count
    FROM expand_orders eo
    GROUP BY user_id
)
SELECT
    os.user_id,
    orders_count,
    round(cast(ps.products_count as decimal) / orders_count, 2) as avg_order_size,
    sum_order_value,
    avg_order_value,
    min_order_value,
    max_order_value
FROM order_stats os
    JOIN product_stats ps on ps.user_id = os.user_id
ORDER BY user_id
