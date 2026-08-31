WITH all_not_canceled_orders as (
    SELECT
        ua.order_id,
        time
    FROM user_actions ua
    WHERE NOT EXISTS (
        SELECT 1
        FROM user_actions ua2
        WHERE ua2.order_id = ua.order_id
          AND ua2.action = 'cancel_order'
    )
),
expand_orders as (
    SELECT
        o.order_id,
        time,
        UNNEST(o.product_ids) as product_id
    FROM orders o
        JOIN all_not_canceled_orders ua on ua.order_id = o.order_id
),
order_prices as (
    SELECT
        cast(time as date) as everyday,
        order_id,
        sum(p.price) as order_price
    FROM expand_orders eo
        LEFT JOIN products p USING(product_id)
    GROUP BY order_id, time
)
SELECT
    everyday as date,
    cast(sum(order_price) as decimal) as revenue
FROM
    order_prices
group by everyday
order by date
