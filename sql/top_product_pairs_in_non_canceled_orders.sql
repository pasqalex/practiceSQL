with all_not_canceled_orders as (
    SELECT
        order_id
    FROM
        user_actions ua1
        left join (
            SELECT
                order_id
            FROM
                user_actions
            where action = 'cancel_order'
        ) ua2 using(order_id)
    where ua2.order_id is null
),
filtered_orders_with_more_than_1_products as (          -- Оставили только заказы с более чем 1 товаром
    SELECT
        order_id
    FROM
        (
        SELECT
        array_length(product_ids, 1) as count_of_products,
        order_id
        FROM
        all_not_canceled_orders
            join orders using(order_id)
        ) count_of_products_in_each_order
    where count_of_products > 1
),
expand_orders as (                                      -- Развернули только неотмененные заказы
    SELECT
        order_id,
        unnest(product_ids) as product_id
    FROM
        orders
        join filtered_orders_with_more_than_1_products using(order_id)
),
rename_values as (
    SELECT
        order_id,
        name
    FROM
        expand_orders
        left join products using(product_id)
)
SELECT
    array[rv1.name, rv2.name] as pair,
    count(DISTINCT(rv1.order_id)) as count_pair
FROM
    rename_values rv1
    cross join rename_values rv2
where rv1.name < rv2.name
    and rv1.order_id = rv2.order_id
group by 1
order by count_pair desc, pair
