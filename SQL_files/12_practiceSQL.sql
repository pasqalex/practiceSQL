WITH all_not_canceled_orders as (
    SELECT
        ua.order_id
    FROM user_actions ua
    WHERE NOT EXISTS (
        SELECT 1
        FROM user_actions ua2
        WHERE ua2.order_id = ua.order_id
          AND ua2.action = 'cancel_order'
    )
),
september_deliver as (
    SELECT
        cast(time as date) as date,
        order_id
    FROM
        courier_actions
    where action = 'deliver_order'
        and time >= '2022-09-01 00:00:00'
            and time < '2022-10-01'
),
expand_orders as (
    SELECT
        count(DISTINCT(o.order_id)) as times_purchased,
        UNNEST(o.product_ids) as product_id
    FROM orders o
        JOIN all_not_canceled_orders ua on ua.order_id = o.order_id
            JOIN september_deliver sd on sd.order_id = o.order_id
    group by product_id
)
SELECT
    name,
    times_purchased
FROM
    expand_orders
        LEFT JOIN products p USING(product_id)
order by 2 desc
limit 10
