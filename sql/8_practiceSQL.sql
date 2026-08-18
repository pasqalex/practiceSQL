-- with canceled_orders as (
--     SELECT
--         order_id
--     FROM
--         user_actions
--     where action = 'cancel_order'
-- ),
-- all_not_canceled_orders as (
--     SELECT
--         order_id
--     FROM
--         user_actions ua
--     where not exists (SELECT
--         order_id
--     FROM
--         user_actions ua2
--     where ua2.order_id = ua.order_id
--         and ua2.action = 'cancel_order')
-- )
SELECT
    user_id, order_id, product_ids
FROM
    (
    SELECT
        order_id, user_id
    FROM
        user_actions ua
    where not exists (SELECT
        order_id, user_id
    FROM
        user_actions ua2
    where ua2.order_id = ua.order_id
        and ua2.action = 'cancel_order')
) all_not_canceled_orders
left join orders o using(order_id)
order by user_id, order_id
limit 1000
