# 🏠 Short-Term Rental Demand vs. Long-Term Housing Rent Inflation in Southern Europe

A macroeconomic ETL, statistical, and Power BI visualization pipeline analyzing the relationship between short-term platform rentals (e.g., Airbnb) and residential lease price growth across **Spain (ES)**, **Italy (IT)**, and **Portugal (PT)** from **2019 to 2024**.

---

## 📌 Executive Summary & Key Analytical Findings

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
* **Storage:** PostgreSQL / SQLite / Clean CSV Exports
* **Business Intelligence:** Power BI Desktop (DAX Time-Intelligence, `DimDate` dimensional modeling)

---

## 🚀 Getting Started

### Prerequisites
* Python 3.9+
* Power BI Desktop (for visual reporting)
* PostgreSQL or SQLite (optional for staging)

### 1. Clone Repository & Setup Virtual Environment
```bash
git clone [https://github.com/your-username/housing-tourism-analysis.git](https://github.com/your-username/housing-tourism-analysis.git)
cd housing-tourism-analysis

python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
2. Run Data Extraction & Processing Script
Bash
python etl_script.py
Outputs generated: airbnb_vs_rent_es_it_pt.csv and housing_tourism_db.db (SQLite).

📈 Power BI Data Model & DAX Measures
The Power BI model utilizes a Star Schema with a dedicated DimDate dimension table linked via a 1:N (One-to-Many) relationship to airbnb_vs_rent_es_it_pt[date].

Key Custom DAX Measures
3-Month Moving Average (Smooths Seasonality):

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
Lead-Lag Pearson Correlation Measure:

Fragment kodu
Lag12_Pearson_Correlation = 
VAR AvgX = CALCULATE(AVERAGE('airbnb_vs_rent_es_it_pt'[airbnb_yoy_pct]), ALLSELECTED('airbnb_vs_rent_es_it_pt'))
VAR AvgY = CALCULATE(AVERAGE('airbnb_vs_rent_es_it_pt'[rent_yoy_pct]), ALLSELECTED('airbnb_vs_rent_es_it_pt'))
VAR N = COUNTROWS('airbnb_vs_rent_es_it_pt')

VAR SampleCovariance = 
    DIVIDE(
        SUMX(
            'airbnb_vs_rent_es_it_pt', 
            ('airbnb_vs_rent_es_it_pt'[airbnb_yoy_pct] - AvgX) * ('airbnb_vs_rent_es_it_pt'[rent_yoy_pct] - AvgY)
        ),
        N - 1,
        0
    )

VAR StDevX = STDEV.S('airbnb_vs_rent_es_it_pt'[airbnb_yoy_pct])
VAR StDevY = STDEV.S('airbnb_vs_rent_es_it_pt'[rent_yoy_pct])

RETURN 
    DIVIDE(SampleCovariance, StDevX * StDevY, BLANK())
⚖️ License & Attribution
Software & Analytics Code: Released under the MIT License.

Data Sources: Re-used under the Eurostat Open Data Terms / Creative Commons Attribution 4.0 International (CC BY 4.0).