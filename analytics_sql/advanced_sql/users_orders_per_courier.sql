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
daily_users as (
    SELECT
        count(DISTINCT user_id) as count_users,
        report_date
    FROM not_canceled_orders
    GROUP BY report_date
),
orders_per_day as (
    SELECT
        count(order_id) as daily_orders,
        report_date
    FROM not_canceled_orders
    GROUP BY report_date
),
count_of_active_couriers as (
    SELECT
        report_date,
        COUNT(DISTINCT courier_id) as active_couriers
    FROM (
        SELECT
            DATE(ca.time) as report_date,
            ca.courier_id
        FROM courier_actions ca
        WHERE ca.action = 'accept_order'
          AND ca.order_id IN (
              SELECT order_id
              FROM courier_actions
              WHERE action = 'deliver_order'
          )

        UNION ALL

        SELECT
            DATE(ca.time) as report_date,
            ca.courier_id
        FROM courier_actions ca
        WHERE ca.action = 'deliver_order'
    ) active
    GROUP BY report_date
)
SELECT
    COALESCE(du.report_date, od.report_date, cac.report_date) as date,
    ROUND(
        count_users / NULLIF(CAST(active_couriers as DECIMAL), 0)
        , 2
    ) as users_per_courier,
    ROUND (
        daily_orders / NULLIF(CAST(active_couriers as DECIMAL), 0)
        , 2
    ) as orders_per_courier
FROM daily_users du
    FULL JOIN orders_per_day od USING(report_date)
    FULL JOIN count_of_active_couriers cac USING(report_date)
ORDER BY report_date
