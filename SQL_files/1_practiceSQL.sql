with best as (
    SELECT courier_id, count(order_id) filter(where action = 'deliver_order') as countOfDels
    FROM courier_actions
    WHERE time >= '2022-09-01'
        and time < '2022-10-01 00:00:00'
    group by courier_id
    having count(order_id) filter(where action = 'deliver_order') >= 30
)
SELECT
    cr.courier_id, cr.birth_date, cr.sex
FROM
    couriers cr
where cr.courier_id in (select courier_id from best)
order by cr.courier_id