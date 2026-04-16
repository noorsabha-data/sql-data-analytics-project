# 📊 Data Analytics Layer – SQL Data Warehouse Project

## 🚀 Overview

This module focuses on **advanced data analysis** built on top of the Gold Layer of the data warehouse.
It transforms structured data into **actionable business insights** using SQL.

The analysis includes:

* Exploratory Data Analysis (EDA)
* Time-series analysis
* Customer behavior analytics
* Product performance analysis
* Segmentation (RFM, Cohort, CLV)
* Customer 360 & Product 360 views

---

## 🧱 Data Source

All analyses are performed on the **Gold Layer**:

* `gold.fact_sales`
* `gold.dim_customers`
* `gold.dim_products`
* `gold.vw_sales_report`

These tables follow a **star schema** optimized for analytics.

---

## 🔍 Analysis Modules

### 1. 🧭 Database Exploration

* Tables, schemas, and metadata inspection
* Row counts and structure validation

---

### 2. 📐 Dimensions Exploration

* Customer distribution (country, gender)
* Product hierarchy (category, subcategory)

---

### 3. 📅 Date Range Analysis

* First and last order dates
* Customer age distribution
* Data coverage period

---

### 4. 📊 Measures Exploration (KPIs)

* Total Sales
* Total Orders
* Total Quantity Sold
* Average Price
* Total Customers & Products

---

### 5. 📦 Magnitude Analysis

* Revenue by category
* Customers by country & gender
* Product distribution across categories

---

### 6. 🏆 Ranking Analysis

* Top & bottom products
* Top customers by revenue
* Low activity customers

---

### 7. ⏳ Time-Based Analysis

* Monthly & yearly sales trends
* Month-over-Month (MoM) growth
* Year-over-Year (YoY) comparison
* Moving averages

---

### 8. 👥 Cohort Analysis

* Customer retention patterns
* Monthly cohort tracking
* Lifecycle behavior insights

---

### 9. 💰 RFM Segmentation

Customers segmented based on:

* **Recency** (last purchase)
* **Frequency** (number of orders)
* **Monetary** (total spend)

Segments include:

* Champions
* Loyal Customers
* At Risk
* Others

---

### 10. 💵 Customer Lifetime Value (CLV)

* Total revenue per customer
* Average order value
* Monthly customer value
* Customer lifespan

---
### 11. 📊 Part-to-Whole Analysis

* Contribution of categories to total revenue
* Cumulative percentage (Pareto 80/20 rule)

---

### 12. 🎯 Segmentation Analysis

* Product segmentation (cost-based)
* Customer segmentation (behavior-based)

---

### 13. 🧠 Customer 360 Analysis

A unified customer view combining:

* Demographics
* RFM segmentation
* CLV
* Cohort data
* Activity status (Active, Warm, Cold)

---

### 14. 📦 Product 360 Analysis

Comprehensive product performance view:

* Sales & revenue
* Customer reach
* Profit & margin
* Product lifecycle
* Pareto analysis (Top 80%)

---

## 📈 Key Business Insights

### 👑 Revenue Concentration

* A small number of products contribute to the majority of revenue (**Pareto Principle**)

---

### 💰 High-Value Customers

* “Champions” and “Loyal Customers” generate most revenue

---

### ⚠️ Churn Risk

* “At Risk” and “Cold” customers show declining engagement

---

### 📦 Product Performance Gap

* Many products fall into the **long tail** with low contribution

---

### 📅 Customer Retention Trends

* Cohort analysis reveals drop-offs after initial purchase periods

---

### 💸 Profit vs Revenue

* High revenue does not always mean high profitability
* Margin analysis is critical

---

## 💡 Business Recommendations

### 🎯 1. Retain High-Value Customers

* Loyalty programs for Champions
* Exclusive offers for repeat buyers

---

### 🔁 2. Re-engage At-Risk Customers

* Email campaigns
* Personalized discounts
* Reminder notifications

---

### 📦 3. Optimize Product Portfolio

* Focus on top-performing products (Top 80%)
* Re-evaluate or remove low-performing products

---

### 💰 4. Improve Profit Margins

* Adjust pricing strategies
* Reduce product costs

---

### 📈 5. Increase Customer Lifetime Value

* Cross-sell and upsell strategies
* Personalized recommendations

---

### 📊 6. Strengthen Early Retention

* Improve onboarding for new customers
* Target early lifecycle engagement

---

## 🧰 Tools & Techniques

* SQL Server (T-SQL)
* Window Functions (`RANK`, `LAG`, `NTILE`, `SUM OVER`)
* CTEs (Common Table Expressions)
* Data Modeling (Star Schema)
* Analytical Techniques (RFM, Cohort, CLV, Pareto)

---

## 🚀 Outcome

This analytics layer transforms raw transactional data into:

* **Strategic insights**
* **Customer intelligence**
* **Data-driven decision support**

It serves as a strong foundation for:

* Business Intelligence dashboards (Power BI / Tableau)
* Advanced analytics
* Data science models

---

## 👤 Author

**Noorsabha Qureshi**
