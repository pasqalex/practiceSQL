with canceled_orders as (
    SELECT DISTINCT order_id
    FROM user_actions
    WHERE action = 'cancel_order'
      AND order_id IS NOT null
),
valid_deliveries as (
    SELECT courier_id, order_id
    FROM courier_actions ca
    WHERE action = 'deliver_order'
      AND order_id IS NOT null
      AND courier_id IS NOT null
      AND NOT EXISTS (
          SELECT 1 
          FROM canceled_orders co
          WHERE co.order_id = ca.order_id
      )
),
courier_stats as (
    SELECT 
        courier_id,
        COUNT(DISTINCT order_id) as orders_count
    FROM valid_deliveries
    GROUP BY courier_id
),
all_couriers as (
    SELECT COUNT(DISTINCT courier_id) as total_count
    FROM courier_actions
    WHERE courier_id IS NOT null
),
ranked as (
    SELECT 
        courier_id,
        orders_count,
        ROW_NUMBER() OVER (
            ORDER BY orders_count desc, courier_id
        ) as courier_rank
    FROM courier_stats
),
limit_calc as (
    SELECT GREATEST(1, cast(CEIL(total_count * 0.1) as integer)) as top_limit
    FROM all_couriers
)
SELECT 
    r.courier_id,
    r.orders_count,
    r.courier_rank
FROM ranked r
CROSS JOIN limit_calc l
WHERE r.courier_rank <= l.top_limit
ORDER BY r.courier_rank
