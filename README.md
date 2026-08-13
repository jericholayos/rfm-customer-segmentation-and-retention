# RFM Customer Segmentation & Retention Analysis

This project is an end-to-end customer analytics solution that applies **RFM (Recency, Frequency, Monetary)** analysis to identify high-value customers, detect churn risk, and support customer retention strategies.

Using PostgreSQL, I built a structured retail database and developed SQL queries with window functions and CTEs to calculate RFM metrics and segment 4,434 customers into five behavioral groups: Champions, Loyal Customers, Potential Loyalists, At Risk, and Lost. The results were connected to Power BI to create an interactive executive dashboard for customer and revenue analysis.


## Dashboard Preview

<img width="805" height="804" alt="image" src="https://github.com/user-attachments/assets/4a3c58d7-ff32-416e-bf93-0d492db712b6" />


## Tools & Technologies

- **Database:** PostgreSQL, pgAdmin
- **Visualization:** Power BI
- **Language:** SQL (DDL, CTEs, Window Functions, Aggregations)

## Key Features

- **RFM Scoring:** Calculated Recency, Frequency, and Monetary values using SQL to classify customer behavior.
- **Customer Segmentation:** Segmented 4,434 customers into five actionable RFM groups for retention analysis.
- **Revenue Contribution Analysis:** Compared customer share versus revenue share to identify high-value segments.
- **Churn Risk Intelligence:** Identified **658 At-Risk customers** representing **$42.2M** in revenue at risk.
- **Interactive Recovery Model:** Built a Power BI What-If parameter to estimate potential revenue recovery based on the number of At-Risk customers targeted.
- **Customer Prioritization:** Ranked high-value At-Risk customers by lifetime spend to support re-engagement campaigns.

## Business Insights

- **Lost** customers represent **42%** of the customer base while contributing **26.5%** of total revenue.
- **Champions** account for only **16%** of customers but generate **24.5%** of revenue, making them the highest-value segment.
- The **At-Risk** segment contains **658 customers** with approximately **$42.2M** in revenue at risk, highlighting a significant retention opportunity.


