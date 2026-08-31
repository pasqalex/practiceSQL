with canceled_orders as (
    SELECT order_id
    FROM user_actions
    WHERE action = 'cancel_order'
),
not_canceled_orders as (
    SELECT order_id
    FROM user_actions ua
    WHERE NOT EXISTS (
        SELECT 1
        FROM canceled_orders co
        WHERE co.order_id = ua.order_id
    )
),
warp as (
    SELECT
        order_date,
        sum(price) as daily_revenue
    FROM (
        SELECT
            order_id,
            creation_time,
            date(creation_time) as order_date,
            unnest(product_ids) as product_id
        FROM orders
        JOIN not_canceled_orders using(order_id)
    ) extended_list
    JOIN products using(product_id)
    GROUP BY order_date
)
SELECT
    order_date,
    daily_revenue,
    round(COALESCE(daily_revenue - prev_revenue, 0), 1) as revenue_growth_abs,
    round(COALESCE((daily_revenue - prev_revenue) / prev_revenue * 100, 0), 1) as revenue_growth_percentage
FROM (
    SELECT 
        order_date, 
        daily_revenue,
        LAG(daily_revenue) OVER (ORDER BY order_date) as prev_revenue
    FROM warp
) dump
