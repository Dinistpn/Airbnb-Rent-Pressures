SELECT 
    geo AS country,
    period_category,
    ROUND(AVG(rent_yoy_pct)::numeric, 2) AS avg_rent_inflation_yoy,
    ROUND(AVG(airbnb_nights)::numeric, 0) AS avg_monthly_airbnb_nights,
    ROUND(AVG(airbnb_yoy_pct)::numeric, 2) AS avg_airbnb_growth_yoy
FROM airbnb_vs_rent
GROUP BY geo, period_category
ORDER BY geo, MIN(date);