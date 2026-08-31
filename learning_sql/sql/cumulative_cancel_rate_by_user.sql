with metrics as (
    SELECT user_id,
           order_id,
           action,
           time,
           count(order_id) filter (where action != 'cancel_order') 
               over (PARTITION BY user_id ORDER BY time) as created_orders,
           count(order_id) filter (where action = 'cancel_order') 
               over (PARTITION BY user_id ORDER BY time) as canceled_orders
    FROM user_actions
)
SELECT user_id,
       order_id,
       action,
       time,
       created_orders,
       canceled_orders,
       COALESCE(round(cast(canceled_orders as decimal) / NULLIF(created_orders, 0), 2), 0) as cancel_rate
FROM metrics
order by user_id, order_id, time
