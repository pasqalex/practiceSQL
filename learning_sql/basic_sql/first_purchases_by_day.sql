with all_canceled_orders as (
SELECT
    order_id
FROM
    user_actions
where action = 'cancel_order'
),
all_not_canceled_orders as ( -- все неотмененные заказы
SELECT
    user_id,
    cast(time as date) as distinct_dates
FROM
    user_actions ua
where not exists (select 1 from all_canceled_orders aco where aco.order_id = ua.order_id)
),
find_minimal_date_of_purchase as (
select
    user_id,
    min(distinct_dates) as first_date_of_purchase
from
    all_not_canceled_orders
group by user_id
)
select
    count(user_id) as first_orders,
    first_date_of_purchase as date
from
    find_minimal_date_of_purchase
group by first_date_of_purchase
order by first_date_of_purchase