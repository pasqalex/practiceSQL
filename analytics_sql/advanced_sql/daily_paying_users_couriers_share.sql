with not_canceled_orders as (
    SELECT
        order_id,
        DATE(time) as report_date,
        user_id
    FROM
        user_actions ua
    WHERE NOT EXISTS (
        SELECT
            order_id
        FROM
            user_actions ua2
        WHERE
            ua2.order_id = ua.order_id
            and action = 'cancel_order'
    )
),

count_of_paying_users as (
    SELECT
        report_date,
        count(DISTINCT user_id) as paying_users
    FROM
        not_canceled_orders
    GROUP BY
        report_date
),

count_of_active_couriers as (
    SELECT
        report_date,
        count(DISTINCT courier_id) as active_couriers
    FROM
        courier_actions ca
        JOIN not_canceled_orders using(order_id)
    GROUP BY
        report_date
),

first_orders as (
    SELECT
        DATE(time_of_first_order) as report_date,
        count(*) as new_users
    FROM (
        SELECT
            user_id,
            min(time) as time_of_first_order
        FROM
            user_actions
        GROUP BY
            user_id
    ) t
    GROUP BY report_date
),

first_delivers as (
    SELECT
        DATE(time_of_first_deliver) as report_date,
        count(*) as new_couriers
    FROM (
        SELECT
            courier_id,
            min(time) as time_of_first_deliver
        FROM
            courier_actions
        GROUP BY
            courier_id
    ) t
    GROUP BY report_date
),

daily_stats as (
    SELECT
        COALESCE(copu.report_date, coac.report_date, fo.report_date, fd.report_date) as report_date,
        COALESCE(copu.paying_users, 0) as paying_users,
        COALESCE(coac.active_couriers, 0) as active_couriers,
        COALESCE(fo.new_users, 0) as new_users,
        COALESCE(fd.new_couriers, 0) as new_couriers
    FROM
        count_of_paying_users copu
        FULL JOIN count_of_active_couriers coac using(report_date)
        FULL JOIN first_orders fo using(report_date)
        FULL JOIN first_delivers fd using(report_date)
),
warp as (
    SELECT
        report_date,
        paying_users,
        active_couriers,
        new_users,
        new_couriers,
        sum(new_users) OVER(pattern) as total_users,
        sum(new_couriers) OVER(pattern) as total_couriers
    FROM
        daily_stats 
WINDOW pattern as (ORDER BY report_date)
    ORDER BY
        report_date
)
SELECT
    report_date,
    paying_users,
    active_couriers,
    round(
        paying_users * 100
            / 
        NULLIF(total_users, 0)
        , 2
    ) as paying_users_share,
    round(
        active_couriers * 100
            / 
        NULLIF(total_couriers, 0)
        , 2
    ) as active_couriers_share
FROM
  warp 
WINDOW pattern as (ORDER BY report_date)
