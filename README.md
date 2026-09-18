# RFM Customer Segmentation & Retention Analysis

This project is an end-to-end customer analytics solution that applies **RFM (Recency, Frequency, Monetary)** analysis to identify high-value customers, detect churn risk, and support customer retention strategies.

Using PostgreSQL, I built a structured retail database and developed SQL queries with window functions and CTEs to calculate RFM metrics and segment 4,434 customers into five behavioral groups: Champions, Loyal Customers, Potential Loyalists, At Risk, and Lost. The results were connected to Power BI to create an interactive executive dashboard for customer and revenue analysis.


## Dashboard Preview

<img width="804" height="806" alt="image" src="https://github.com/user-attachments/assets/af9352b5-3170-4829-9499-91442b232f51" />


## Tools & Technologies

- **Database:** PostgreSQL, pgAdmin
- **Visualization:** Power BI
- **Language:** SQL (DDL, CTEs, Window Functions, Aggregations)

## Key Features

* **RFM Scoring:** Used SQL to calculate Recency, Frequency, and Monetary scores for each customer.
* **Customer Segmentation:** Grouped 4,434 customers into five RFM segments.
* **Revenue Analysis:** Compared each customer segment's size and revenue contribution.
* **At-Risk Customers:** Found 658 At-Risk customers with $42.2M in total revenue.
* **Recovery Estimate:** Created a Power BI What-If parameter to estimate how much revenue could be recovered by targeting At-Risk customers.
* **Customer Ranking:** Ranked At-Risk customers by total spending to help identify who to target first.

## Business Insights

- **Lost** customers represent **42%** of the customer base while contributing **26.5%** of total revenue.
- **Champions** account for only **16%** of customers but generate **24.5%** of revenue, making them the highest-value segment.
- The **At-Risk** segment contains **658 customers** with approximately **$42.2M** in revenue at risk, highlighting a significant retention opportunity.


