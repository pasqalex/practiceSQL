with not_canceled_orders as (
    SELECT
        order_id,
        user_id,
        DATE(time) as report_date
    FROM user_actions ua
    WHERE NOT EXISTS (
        SELECT 1
        FROM user_actions ua2
        WHERE ua2.order_id = ua.order_id
            AND action = 'cancel_order'
    )
),
active_users as (
    SELECT
        report_date,
        COUNT(DISTINCT user_id) as count_active_users
    FROM not_canceled_orders
    GROUP BY report_date
),
all_users as (
    SELECT
        DATE(time) as report_date,
        COUNT(DISTINCT user_id) as total_users
    FROM user_actions
    GROUP BY report_date
),
daily_stats as (
    SELECT
        report_date,
        COALESCE(SUM(price), 0) as daily_revenue,
        COUNT(DISTINCT order_id) as total_orders
    FROM (
        SELECT
            order_id,
            user_id,
            report_date,
            UNNEST(product_ids) as product_id
        FROM orders
            JOIN not_canceled_orders USING(order_id)
    ) t1
        JOIN products USING(product_id)
    GROUP BY report_date
)
SELECT
    COALESCE(ds.report_date, au.report_date, a.report_date) as report_date,
    ROUND(
        daily_revenue / NULLIF(total_users, 0)
        , 2
    ) as arpu,
    ROUND(
        daily_revenue / NULLIF(count_active_users, 0)
        , 2
    ) as arppu,
    ROUND(
        daily_revenue / NULLIF(total_orders, 0)
        , 2
    ) as aov
FROM daily_stats ds
    FULL JOIN active_users au USING(report_date)
    FULL JOIN all_users a USING(report_date)
ORDER BY report_date
