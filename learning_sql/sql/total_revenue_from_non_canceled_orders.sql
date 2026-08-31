with all_not_canceled_orders as (
    SELECT
        order_id
    FROM
        user_actions ua
    where not exists (SELECT
        order_id
    FROM
        user_actions ua2
    where ua2.order_id = ua.order_id
        and ua2.action = 'cancel_order')
),
price_of_not_canceled_orders as (
SELECT
    order_id,
    sum(price) as sum_price_of_current_order
FROM
    (select order_id,
            UNNEST(product_ids) as product_id
     from orders o 
     where exists (
            select 1 
            from all_not_canceled_orders anco 
            where o.order_id = anco.order_id)) expanded_orders
    left join products using(product_id)
group by order_id
)
SELECT
    sum(sum_price_of_current_order)
FROM price_of_not_canceled_orders
