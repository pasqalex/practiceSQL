with not_canceled_orders as (
    SELECT
        user_id,
        order_id,
        time,
        DATE(time) as report_date
    FROM
        user_actions ua
    WHERE NOT EXISTS ( 
        SELECT 1
        FROM user_actions ua2
        WHERE ua2.order_id = ua.order_id
            AND action = 'cancel_order'
    )
),
calculate_first_orders as (
    SELECT
        DATE(min_time) as report_date,
        count(*) as first_orders
    FROM (
        SELECT
            user_id,
            MIN(time) as min_time
        FROM not_canceled_orders
        GROUP BY user_id
    ) t1
    GROUP BY report_date
),
order_summary as (
    SELECT
        report_date,
        count(order_id) FILTER(WHERE report_date = DATE(min_time)) as new_users_orders,
        count(order_id) as orders 
    FROM
        not_canceled_orders nco
        JOIN (
            SELECT
                user_id,
                MIN(time) as min_time
            FROM user_actions
            GROUP BY user_id
        ) t2 USING(user_id)
    GROUP BY nco.report_date
)
SELECT
    COALESCE(cfo.report_date, os.report_date) as report_date,
    orders,
    first_orders,
    new_users_orders,
    ROUND(
        first_orders / NULLIF(CAST(orders as DECIMAL), 0) * 100
        , 2
    ) as first_orders_share,
    ROUND(
        new_users_orders / NULLIF(CAST(orders as DECIMAL), 0) * 100
        , 2
    ) as new_users_orders_share
FROM calculate_first_orders cfo
    FULL JOIN order_summary os USING(report_date)
ORDER BY report_date
