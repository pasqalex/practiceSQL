SELECT
    request_at as "Day",
    ROUND (
        CAST(COUNT(id) FILTER(WHERE status != 'completed') as DECIMAL)
        / 
        NULLIF(COUNT(id), 0)
        , 2
    ) as "Cancellation Rate"
FROM trips t
WHERE NOT EXISTS (
    SELECT 1
    FROM users u
    WHERE u.users_id = t.client_id
        AND u.banned ='Yes'
)
    AND NOT EXISTS (
    SELECT 1
    FROM users u
    WHERE u.users_id = t.driver_id
        AND u.banned ='Yes'
)
    AND request_at BETWEEN '2013-10-01' AND '2013-10-03'
GROUP BY request_at
