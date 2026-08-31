with all_canceled_orders as (
SELECT order_id
FROM user_actions
WHERE action = 'cancel_order'
),
all_not_canceled_orders as (
SELECT order_id
FROM user_actions ua
WHERE not exists (select 1 from all_canceled_orders aco WHERE aco.order_id = ua.order_id)
),
top_purchases as MATERIALIZED(
SELECT count(order_id) as times_purchased, unnest(product_ids) as product_id
FROM orders o
where exists (select 1 from all_not_canceled_orders aco WHERE aco.order_id = o.order_id)
group by 2
order by 1 desc
limit 10
)
SELECT
    times_purchased, product_id
FROM 
    top_purchases
order by 2