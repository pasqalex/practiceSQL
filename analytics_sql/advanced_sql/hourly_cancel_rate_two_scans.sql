WITH canceled_orders as (
    SELECT order_id
    FROM user_actions
    WHERE action = 'cancel_order'
),
hour_not_canceled_orders as (
    SELECT
        count(order_id) as successful_orders,
        CAST(EXTRACT(hour from creation_time) as INTEGER) as report_hour
    FROM orders o
    WHERE NOT EXISTS (
        SELECT 1
        FROM canceled_orders co
        WHERE co.order_id = o.order_id
    )
    GROUP BY report_hour
),
hour_canceled_orders as (
    SELECT
        count(order_id) as canceled_orders,
        CAST(EXTRACT(hour from creation_time) as INTEGER) as report_hour
    FROM orders o
    WHERE EXISTS (
        SELECT 1
        FROM canceled_orders co
        WHERE co.order_id = o.order_id
    )
    GROUP BY report_hour
)
SELECT
    COALESCE(hn.report_hour, hc.report_hour) as report_hour,
    COALESCE(successful_orders, 0) as successful_orders,
    COALESCE(canceled_orders, 0) as canceled_orders,
    ROUND(
        canceled_orders / NULLIF(CAST(successful_orders + canceled_orders as DECIMAL), 0)
        , 3
    ) as cancel_rate
FROM hour_not_canceled_orders hn
    FULL JOIN hour_canceled_orders hc USING(report_hour)
ORDER BY report_hour ASC
