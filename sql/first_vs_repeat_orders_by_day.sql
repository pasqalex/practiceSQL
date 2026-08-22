with canceled_orders as (
    SELECT order_id
    FROM user_actions
    WHERE action = 'cancel_order'
),
all_not_canceled_orders as (
    SELECT
        user_id,
        order_id,
        time
    FROM user_actions ua
    WHERE not exists (select 1 from canceled_orders co where co.order_id = ua.order_id)
),
find_the_meaning_of_life as (
    SELECT
        cast(time as date) as date,
        order_id,
        case
            when rank() OVER(PARTITION BY user_id ORDER BY time) = 1
                then 'Первый'
            else 'Повторный' 
        end as order_type
    FROM all_not_canceled_orders
)
SELECT
    date,
    order_type,
    count(order_id) as orders_count
FROM
    find_the_meaning_of_life
group by order_type, orders_count
order by order_type, orders_count
