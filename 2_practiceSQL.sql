with deliver as 
(
SELECT
    order_id
FROM
    courier_actions
where action = 'deliver_order'
order by time desc
offset 0 rows fetch first 100 rows only
)
SELECT
    order_id,
    product_ids
FROM
    orders
where order_id in (select order_id from deliver)
order by order_id