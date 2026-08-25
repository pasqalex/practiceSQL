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
courier_stats as (
    SELECT
        courier_id,
        count(order_id) as delivered_orders,
        ceil(
            EXTRACT(DAY FROM 
                AGE(
                    (SELECT max(time)
                    FROM courier_actions),
                    min(time)
                )
            )
        ) as days_employed
    FROM courier_actions
    WHERE action = 'accept_order'
        AND order_id IN (
        SELECT order_id
        FROM not_canceled_orders
    )
    GROUP BY courier_id
)
SELECT 
    courier_id,
    delivered_orders,
    days_employed
FROM courier_stats
WHERE days_employed >= 10
ORDER BY days_employed desc, courier_id

///////////////////////////////////////////////////////////////////////

SELECT
    courier_id,
    AGE(MAX(time), min(time)) as raw_age,
    EXTRACT(DAY FROM AGE(MAX(time), min(time))) as day_part,
    EXTRACT(EPOCH FROM AGE(MAX(time), min(time))) / 86400 as days_float
FROM courier_actions
WHERE courier_id = 42
GROUP BY courier_id
