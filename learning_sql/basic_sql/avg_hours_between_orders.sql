with canceled_orders as (
    SELECT order_id
    FROM user_actions
    WHERE action = 'cancel_order'
),
all_not_canceled_orders as (
    SELECT
        user_id,
        order_id,
        time,
        count(order_id) OVER(PARTITION BY user_id) as count_of_orders_per_user
    FROM user_actions ua
    WHERE not exists (select 1 from canceled_orders co where co.order_id = ua.order_id
    )
),
some_values as (
    SELECT
        user_id,
        time,
        order_id,
        lag(time) OVER(PARTITION BY user_id order by time) as time_lag
    FROM
        all_not_canceled_orders
    where count_of_orders_per_user > 1
)
SELECT
    user_id,
    cast(round(avg(extract(epoch from age(time, time_lag)) / 3600)) as integer) as hours_between_orders
FROM
    some_values
group by user_id
order by user_id
limit 1000
