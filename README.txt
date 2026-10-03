# 🏠 Short-Term Rental Demand vs. Long-Term Housing Rent Inflation in Southern Europe

A macroeconomic ETL, statistical analysis, and Power BI dashboard project investigating the relationship between short-term platform rentals (e.g., Airbnb) and residential lease price growth across **Spain (ES)**, **Italy (IT)**, and **Portugal (PT)** from **2019 to 2024**.

---

## 📌 Executive Summary & Key Findings

A common policy assumption is that expansion in short-term tourist rentals immediately drives up residential rents. However, this macro statistical analysis reveals a **time-lagged transmission mechanism**:

1. **Negligible Instantaneous Correlation (0-Month Lag):** Direct month-to-month correlation between Airbnb demand growth and housing rent inflation hovers near zero ($r \approx -0.04$ for Spain, $+0.08$ for Italy, $-0.14$ for Portugal).
2. **Strong Leading Indicator Effect (12-Month Lag):** Short-term rental growth acts as a **6 to 12-month leading indicator** for housing market rent spikes as residential lease contracts come up for annual renewal:
   * **Spain (ES):** Correlation rises from **-0.04** at 0 months to **+0.59** at 12 months.
   * **Italy (IT):** Correlation rises from **+0.08** at 0 months to **+0.51** at 12 months.
   * **Portugal (PT):** Correlation rises from **-0.14** at 0 months to **+0.34** at 12 months.

---

## 📊 Summary Statistics (2019–2024)

| Country | Avg. Annual Housing Rent Growth (YoY) | Avg. Annual Airbnb Demand Growth (YoY) | 0-Month Pearson Correlation ($r$) | 12-Month Lagged Correlation ($r$) |
| :--- | :---: | :---: | :---: | :---: |
| **Spain (ES)** | **1.48%** | **32.79%** | -0.042 | **+0.594** |
| **Italy (IT)** | **1.22%** | **32.97%** | +0.086 | **+0.514** |
| **Portugal (PT)** | **3.63%** | **31.64%** | -0.139 | **+0.335** |

---

## 🛠️ Data Pipeline & Architecture

                   [ Eurostat API ]
                          │
      ┌───────────────────┴───────────────────┐
      ▼                                       ▼
Housing Rent Index                   Collaborative Economy
(prc_hicp_midx)                        (tour_ce_omdnms)
│                                       │
└───────────────────┬───────────────────┘
▼
[ Python ETL Script ]
(JSON-stat Matrix Parsing & Reshaping)
│
┌───────────────────┴───────────────────┐
▼                                       ▼
airbnb_vs_rent_es_it_pt.csv             Local SQLite / Postgres
│
▼
[ Power BI Dashboard ]
(DimDate 1:N Data Model & Custom DAX Measures)


### 1. Data Sources (Eurostat Open Data)
* **Housing Rents:** Eurostat HICP dataset `prc_hicp_midx` (`coicop=CP0411` - Actual rentals for housing, `unit=I15`).
* **Platform Rentals:** Eurostat Collaborative Economy dataset `tour_ce_omdnms` (`unit=NR` - Number of guest nights spent).

### 2. Tech Stack
* **Language / ETL:** Python (`pandas`, `requests`, `sqlalchemy`, `numpy`)
* **Database:** PostgreSQL (pgAdmin 4) / SQLite
* **Business Intelligence:** Power BI Desktop (DAX Time-Intelligence, `DimDate` star schema)

---

## 📁 Repository Structure

```text
Airbnb-Rent-Pressures/
│
├── .gitignore                   # Excludes raw cache, virtual envs, and temporary files
├── LICENSE                      # Dual license (MIT for code, CC BY 4.0 for data)
├── README.md                    # Project documentation and summary
├── requirements.txt             # Python dependencies
│
├── data/                        # Dataset directory
│   └── processed/
│       └── airbnb_vs_rent_es_it_pt.csv   # Aggregated dataset (2019-2024)
│
├── src/                         # Python ETL source code
│   ├── extract.py               # Eurostat API extraction
│   └── transform.py             # Data transformation & feature engineering
│
├── sql/                         # Database scripts
│   ├── schema.sql               # DDL table creation for PostgreSQL/pgAdmin
│   └── analysis_queries.sql     # Lagged correlation & 3MA SQL queries
│
└── power_bi/                    # Power BI deliverables
    ├── Airbnb_Rent_Pressures.pbix   # Power BI Desktop report file
    └── measures.dax             # Custom DAX calculations backup
🚀 Getting Started
Prerequisites
Python 3.9+

Power BI Desktop

PostgreSQL / pgAdmin 4 or SQLite

1. Clone Repository & Setup Environment
Bash
git clone [https://github.com/Dinistpn/Airbnb-Rent-Pressures.git](https://github.com/Dinistpn/Airbnb-Rent-Pressures.git)
cd Airbnb-Rent-Pressures

python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
2. Execute Data Pipeline
Bash
python src/extract.py
python src/transform.py
Generated output: Saved to data/processed/airbnb_vs_rent_es_it_pt.csv.

📈 Key DAX & SQL Analytical Calculations
1. 3-Month Moving Average DAX Measure (Power BI)
Calculates smoothed 3-month moving averages across monthly dates to remove high summer seasonality:

Fragment kodu
Airbnb_Nights_3MA = 
VAR CurrentDate = MAX('airbnb_vs_rent_es_it_pt'[date])
VAR StartDate = EDATE(CurrentDate, -2)
RETURN
    CALCULATE(
        AVERAGE('airbnb_vs_rent_es_it_pt'[airbnb_nights]),
        REMOVEFILTERS(DimDate),
        'airbnb_vs_rent_es_it_pt'[date] >= StartDate &&
        'airbnb_vs_rent_es_it_pt'[date] <= CurrentDate,
        VALUES('airbnb_vs_rent_es_it_pt'[geo])
    )
2. Lagged Pearson Correlation SQL Query (PostgreSQL / pgAdmin)
SQL
WITH lagged_data AS (
    SELECT 
        geo,
        date,
        rent_yoy_pct,
        LAG(airbnb_yoy_pct, 12) OVER (PARTITION BY geo ORDER BY date) AS airbnb_yoy_lag12
    FROM airbnb_vs_rent
)
SELECT 
    geo AS country,
    COUNT(*) AS sample_size,
    ROUND(CORR(airbnb_yoy_lag12, rent_yoy_pct)::numeric, 4) AS pearson_corr_12m_lag
FROM lagged_data
WHERE airbnb_yoy_lag12 IS NOT NULL 
GROUP BY geo
ORDER BY geo;

⚖️ License & Attribution
Software & Code: Released under the MIT License.

Data Sources: Re-used under Eurostat Open Data Terms / Creative Commons Attribution 4.0 International (CC BY 4.0).
