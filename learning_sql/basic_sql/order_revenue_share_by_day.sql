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
        order_id,
        creation_time,
        order_date,
        sum(price) as order_price,
        sum(sum(price)) OVER(PARTITION BY order_date) as daily_revenue
            -- Могла быть реализована через CTE
    FROM (
        SELECT
            order_id,
            creation_time,
            cast(creation_time as date) as order_date,
            unnest(product_ids) as product_id
        FROM
            orders
            JOIN not_canceled_orders using(order_id)
    ) expanded_list
        JOIN products p using(product_id)
        GROUP BY order_id, order_date, creation_time
)
SELECT
    order_id,
    creation_time,
    order_price,
    daily_revenue,
    round(cast(order_price as decimal) / NULLIF(daily_revenue, 0) * 100, 3) as percentage_of_daily_revenue
FROM
    warp
ORDER BY order_date desc, percentage_of_daily_revenue desc, order_id
