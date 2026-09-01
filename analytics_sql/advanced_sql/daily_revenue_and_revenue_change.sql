with expand_products as (
    SELECT
        order_id,
        DATE(creation_time) as report_date,
        UNNEST(product_ids) as product_id
    FROM orders o
    WHERE NOT EXISTS (
        SELECT order_id
        FROM user_actions ua
        WHERE ua.order_id = o.order_id
            AND action = 'cancel_order'
    )
),
calculate as (
    SELECT
        report_date,
        SUM(price) as revenue,
        SUM(SUM(price)) OVER(ORDER BY report_date) as total_revenue
    FROM expand_products ep
        JOIN products p USING(product_id)
    GROUP BY report_date
)
SELECT 
    report_date as date,
    revenue,
    total_revenue,
    ROUND(
        (revenue - LAG(revenue, 1) OVER(pattern)) 
            /
        NULLIF(CAST(LAG(revenue, 1) OVER(pattern) as DECIMAL), 0) * 100
        , 2
    ) as revenue_change 
FROM calculate
WINDOW pattern as (ORDER BY report_date)
ORDER BY report_date
