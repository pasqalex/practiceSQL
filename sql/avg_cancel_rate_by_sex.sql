with all_canceled_orders as materialized(
    SELECT order_id
    FROM user_actions
    WHERE action = 'cancel_order'
),
count_of_orders as (
    SELECT
        user_id,
        count(DISTINCT order_id) filter (
            WHERE EXISTS (
                SELECT 1
                FROM all_canceled_orders aco
                WHERE aco.order_id = ua.order_id
            )
        ) as count_of_canceled_orders,
        count(DISTINCT order_id) filter (
            WHERE NOT EXISTS (
                SELECT 1
                FROM all_canceled_orders aco
                WHERE aco.order_id = ua.order_id
            )
        ) as count_of_not_canceled_orders
    FROM user_actions ua
    GROUP BY user_id
),
-- В качестве альтернативы, не заслужившей отдельного файла,
-- можно рассмотреть замену CTE <<count_of_orders>>
-- на следующий вариант, который, по анализу explain работает лучше:
-- count_of_orders as (
--     SELECT
--         user_id,
--         count(DISTINCT ua.order_id) filter(where aco.order_id is not null) as count_of_canceled_orders,
--         count(DISTINCT ua.order_id) filter(where aco.order_id is null) as count_of_not_canceled_orders
--     FROM user_actions ua
--         left join all_canceled_orders aco on aco.order_id = ua.order_id
--     GROUP BY user_id
-- ),
user_cancel_rate as (
    SELECT
        user_id,
        round(
            cast(count_of_canceled_orders as decimal)
            / NULLIF(count_of_canceled_orders + count_of_not_canceled_orders, 0), 2) as cancel_rate
    FROM count_of_orders
)
SELECT
    coalesce(sex, 'unknown') as sex,
    round(avg(cancel_rate), 3) as avg_cancel_rate
FROM user_cancel_rate
LEFT JOIN users using(user_id)
GROUP BY sex
