WITH lagged_data AS (
    SELECT 
        geo,
        date,
        rent_yoy_pct,
        LAG(airbnb_yoy_pct, 12) OVER (
            PARTITION BY geo 
            ORDER BY date
        ) AS airbnb_yoy_lag12
    FROM airbnb_vs_rent
)
SELECT 
    geo AS country,
    COUNT(*) AS sample_size,
    ROUND(CORR(airbnb_yoy_lag12, rent_yoy_pct)::numeric, 4) AS pearson_corr_12m_lag
FROM lagged_data
WHERE airbnb_yoy_lag12 IS NOT NULL 
  AND rent_yoy_pct IS NOT NULL
GROUP BY geo
ORDER BY geo;