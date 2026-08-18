with CalcAge as (
    SELECT
        max(time) as max_time
    FROM
        user_actions
),
avgAge as (
    select cast(to_timestamp(avg(extract(epoch from birth_date))) as date) as avgOfAge
    from users
)
SELECT
    user_id,
    cast(extract(year from age((select max_time from CalcAge), coalesce(birth_date, (select avgOfAge from avgAge)))) as integer) as age
FROM
    users
order by user_id