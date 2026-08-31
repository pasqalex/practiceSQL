with not_canceled_orders as (
    SELECT
        order_id,
        DATE(time) as report_date,
        user_id
    FROM
        user_actions ua
    WHERE NOT EXISTS (
        SELECT 1
        FROM user_actions ua2
        WHERE
            ua2.order_id = ua.order_id
            and action = 'cancel_order'
    )
),

count_of_orders as (
    SELECT
        report_date,
        user_id,
        count(order_id) as count_of_orders_per_user
    FROM not_canceled_orders
    GROUP BY user_id, report_date
),

order_stats as (
    SELECT
        report_date,
        COUNT(DISTINCT user_id) as paying_users,
        COUNT(user_id) FILTER (WHERE count_of_orders_per_user = 1) as single_orders,
        COUNT(user_id) FILTER (WHERE count_of_orders_per_user > 1) as several_orders
    FROM count_of_orders
    GROUP BY report_date
)
SELECT
    report_date,
    round(
        cast(single_orders as decimal) / NULLIF(paying_users, 0) * 100
        , 2
    ) as single_order_users_share,
    round(
        cast(several_orders as decimal) / NULLIF(paying_users, 0) * 100
        , 2
    ) as several_orders_users_share
FROM order_stats
ORDER BY report_date
