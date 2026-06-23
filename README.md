## Project Overview

This repository contains the version 2 of my end-to-end data analytics project focused on Customer RFM (Recency, Frequency, Monetary) Segmentation and Retention Intelligence. The goal of this project is to analyze customer purchasing behavior, identify high-value shoppers, and highlight revenue at risk due to customer churn.

Using PostgreSQL and pgAdmin, I built a structured retail database and wrote SQL queries to calculate RFM scores. These scores group customers into five distinct categories: Champions, Loyal Customers, Potential Loyalists, At Risk, and Lost. I then connected the database to Power BI to create interactive dashboards that visualize these insights for clear business decision-making.

## Dashboard Preview
<img width="1920" height="1080" alt="Segment Overview " src="https://github.com/user-attachments/assets/7a50991c-2add-4b30-8642-9ab80ecbaa7f" />
<img width="1920" height="1080" alt="Retention and Risk" src="https://github.com/user-attachments/assets/37a2f3fd-91a4-4a41-ba95-368ad5e899e4" />



## Tools and Technologies

* **Database:** PostgreSQL, pgAdmin
* **Data Visualization:** Power BI
* **Language:** SQL (DDL, Data Exploration, Window Functions, CTEs)

## Key Features and Analysis

* **RFM Scoring Model:** Developed SQL scripts to calculate how recently a customer bought, how often they buy, and how much they spend.
* **Customer Segmentation:** Applied logic to categorize customers into actionable tiers. For example, the analysis reveals that Champions make up only 16% of the customer base but generate over 24% of the total revenue.
* **Retention and Risk Dashboards:** Built a comprehensive Power BI report featuring revenue share by segment, geographic loss concentration, and a breakdown of return rates. The dashboard helps prioritize re-engagement strategies by highlighting the top At Risk customers by lifetime spend.


