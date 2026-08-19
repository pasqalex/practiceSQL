with expand_orders as (
    SELECT
        order_id,
        array_length(product_ids, 1) as count_of_products_in_order
    FROM
        orders
),
max_of_orders as (
    SELECT
        max(count_of_products_in_order) as max_value_of_order
    FROM
        expand_orders
),
order_ids_with_max_count_of_products as (
    SELECT
        order_id
    FROM
        expand_orders
    where exists (select 1 
                  from max_of_orders
                  where max_value_of_order = count_of_products_in_order
                 )
),
couriers_ids as (
    SELECT
        order_id,
        courier_id,
        ua.user_id
    FROM
        courier_actions ca
        join order_ids_with_max_count_of_products oiwmc using(order_id)
            join user_actions ua using(order_id)
    where ca.action = 'deliver_order'
),
starting_point_for_age as (
    SELECT max(cast(time as date)) as max_date
    FROM user_actions
)
SELECT
    courier_id,
    user_id, 
    order_id,
    cast(extract(year from age(sp.max_date, u.birth_date)) as integer) as user_age,
    cast(extract(year from age(sp.max_date, c.birth_date)) as integer) as courier_age
FROM
    couriers_ids
    cross join starting_point_for_age sp
    join users u using(user_id)
        join couriers c using(courier_id)
order by courier_id
