with canceled_orders as (
    SELECT order_id
    FROM user_actions
    WHERE action = 'cancel_order'
),
all_not_canceled_orders as (
    SELECT
        courier_id,
        order_id
    FROM user_actions ua
    join courier_actions ca using(order_id)
    WHERE not exists (select 1 from canceled_orders co where co.order_id = ua.order_id)
        and ca.action = 'deliver_order'
            and (ca.time >= '2022-09-01 00:00:00' and ca.time < '2022-10-01 00:00:00')
),
some_values as (
    SELECT
        courier_id,
        count(order_id) as delivered_orders
    FROM all_not_canceled_orders
    GROUP BY 1
)
SELECT
    courier_id,
    delivered_orders,
    case
        when delivered_orders > avg(delivered_orders) over()
            then '1'
        when delivered_orders < avg(delivered_orders) over()
            then '0'
        else 'окак'
    end as is_above_avg,
    round(avg(delivered_orders) over(), 2) as avg_delivered_orders
FROM
    some_values
order by courier_id
