SELECT 
    geo AS country,
    date,
    -- Raw Values
    rent_yoy_pct AS raw_rent_yoy_pct,
    airbnb_yoy_pct AS raw_airbnb_yoy_pct,
    airbnb_nights AS raw_airbnb_nights,
    
    -- 3-Month Moving Averages (3MA)
    ROUND(
        AVG(rent_yoy_pct) OVER (
            PARTITION BY geo 
            ORDER BY date 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )::numeric, 2
    ) AS rent_yoy_pct_3ma,
    
    ROUND(
        AVG(airbnb_yoy_pct) OVER (
            PARTITION BY geo 
            ORDER BY date 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )::numeric, 2
    ) AS airbnb_yoy_pct_3ma,
    
    ROUND(
        AVG(airbnb_nights) OVER (
            PARTITION BY geo 
            ORDER BY date 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )::numeric, 0
    ) AS airbnb_nights_3ma

FROM airbnb_vs_rent
ORDER BY geo, date;