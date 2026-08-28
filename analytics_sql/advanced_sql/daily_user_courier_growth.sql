with first_orders as (
    SELECT 
        DATE(time_of_first_order) as report_date,
        count(*) as new_users
    FROM (
        SELECT 
            user_id, 
            MIN(time) as time_of_first_order
        FROM user_actions
        GROUP BY user_id
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
            MIN(time) as time_of_first_deliver
        FROM courier_actions
        GROUP BY courier_id
    ) t
    GROUP BY report_date
),
daily_stats as (
    SELECT 
        COALESCE(f.report_date, d.report_date) as report_date,
        COALESCE(f.new_users, 0) as new_users,
        COALESCE(d.new_couriers, 0) as new_couriers
    FROM first_orders f
    FULL JOIN first_delivers d using(report_date)
),
warp as (
    SELECT
        report_date,
        new_users,
        new_couriers,
        sum(new_users) OVER(pattern) as total_users,
        sum(new_couriers) OVER(pattern) as total_couriers,
        round(
            cast(new_users - LAG(new_users, 1) OVER(pattern) as decimal)
                / 
            NULLIF(LAG(new_users, 1) OVER(pattern), 0) * 100
            , 2
        ) as new_users_change,
        round(
            cast(new_couriers - LAG(new_couriers, 1) OVER(pattern) as decimal)
                / 
            NULLIF(LAG(new_couriers, 1) OVER(pattern), 0) * 100
            , 2
        ) as new_couriers_change
    FROM daily_stats
    WINDOW 
    pattern AS 
    (
    ORDER BY report_date
    )
    ORDER BY report_date
)
SELECT
    report_date,
    new_users,
    new_couriers,
    new_users_change,
    new_couriers_change,
    total_users,
    total_couriers,
    round(
        cast(total_users - LAG(total_users, 1) OVER(pattern) as decimal)
            /
        NULLIF(LAG(total_users, 1) OVER(pattern), 0) * 100
        , 2
    ) as total_users_growth,
    round(
        cast(total_couriers - LAG(total_couriers, 1) OVER(pattern) as decimal) 
            /
        NULLIF(LAG(total_couriers, 1) OVER(pattern), 0) * 100
        , 2
    ) as total_couriers_growth
FROM
    warp
WINDOW 
    pattern AS 
    (
    ORDER BY report_date
    )