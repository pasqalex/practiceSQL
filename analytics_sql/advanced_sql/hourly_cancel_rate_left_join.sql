-- Первый вариант
WITH canceled_orders as (
    SELECT order_id
    FROM user_actions
    WHERE action = 'cancel_order'
)
SELECT
    CAST(EXTRACT(hour from o.creation_time) as INTEGER) as report_hour,
    count(*) FILTER(WHERE co.order_id IS NULL) as successful_orders,
    count(*) FILTER(WHERE co.order_id IS NOT NULL) as canceled_orders,
    ROUND(
        CAST(count(*) FILTER (WHERE co.order_id IS NOT NULL) as DECIMAL)
        / NULLIF(count(*), 0),
        3
    ) as cancel_rate
FROM orders o
LEFT JOIN canceled_orders co USING(order_id)
GROUP BY report_hour
ORDER BY report_hour
