WITH large_orders AS (
    SELECT order_id
    FROM orders
    WHERE array_length(product_ids, 1) > 5
),
not_cancelled AS (
    SELECT lo.order_id
    FROM large_orders lo
    WHERE EXISTS (
        SELECT 1
        FROM user_actions ua
        WHERE ua.order_id = lo.order_id
          AND ua.action != 'cancel_order'
    )
),
accept_times AS (
    SELECT ca.order_id, ca.time AS accept_time
    FROM courier_actions ca
    WHERE ca.action = 'accept_order'
      AND EXISTS (SELECT 1 FROM not_cancelled nc WHERE nc.order_id = ca.order_id)
)
SELECT
    a.order_id,
    a.accept_time,
    (SELECT ca.time
     FROM courier_actions ca
     WHERE ca.action = 'deliver_order'
       AND ca.order_id = a.order_id
     LIMIT 1) AS deliver_time,
    AGE(
        (SELECT ca.time
         FROM courier_actions ca
         WHERE ca.action = 'deliver_order'
           AND ca.order_id = a.order_id
         LIMIT 1),
        a.accept_time
    ) AS delivery_duration
FROM accept_times a
ORDER BY a.order_id;