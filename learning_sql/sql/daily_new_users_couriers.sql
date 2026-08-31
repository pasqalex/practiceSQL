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
    FULL JOIN first_delivers d USING (report_date)
)
SELECT
    report_date,
    new_users,
    new_couriers,
    sum(new_users) OVER(ORDER BY report_date) as total_users,
    sum(new_couriers) OVER(ORDER BY report_date) as total_couriers
FROM daily_stats
ORDER BY report_date
