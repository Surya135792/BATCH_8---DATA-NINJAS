# TEAM_8---DATA-NINJAS

🧠 RetailPulse – End-to-End Data Engineering Pipeline
📌 Project Overview :
RetailPulse is an end-to-end data engineering project designed to process retail datasets and generate meaningful business insights.
The pipeline is built using Snowflake and AWS S3, following the Medallion Architecture (Bronze → Silver → Gold) to ensure scalability, data quality, and efficient analytics.

🏗️ Architecture
AWS S3 → Snowpipe → Bronze → Silver → Gold → Power BI
                ↓
             Streams
                ↓
              Tasks (DAG)
              
🔹 Bronze Layer
Raw data ingestion from AWS S3

Stores data as-is with metadata (SOURCE_FILE, LOAD_TS)

🔹 Silver Layer
Data cleaning and transformation

Handles nulls, duplicates, and formatting

🔹 Gold Layer
Business-ready data model

Fact & Dimension tables (Star Schema)

Supports analytics and reporting

⚙️ Technologies Used
❄️ Snowflake (Data Warehouse)

☁️ AWS S3 (Data Storage)

🧾 SQL (Data Transformation)

📊 Power BI (Visualization)

👥 Team Roles & Responsibilities
🔹 Ingestion Role
Created database, schemas, and warehouse

Configured S3 integration and external stages

Defined file formats

Loaded initial data using COPY INTO

Implemented Snowpipe for real-time ingestion

Created Streams for incremental processing

🔹 Cleaning Role (Silver Layer)
Removed null and invalid records

Deduplicated data using ROW_NUMBER()

Standardized text using TRIM and UPPER

Applied safe conversions using TRY_TO_DATE

Used MERGE for idempotent data loading

🔹 Transformation Role (Gold Layer)
Designed Star Schema (Fact & Dimension tables)

Implemented SCD Type 2 for historical tracking

Created surrogate keys for efficient joins

Built Fact_Sales table for analytics

🔹 Automation Role
Implemented Streams for change data capture

Created Tasks for automation

Built DAG using AFTER dependencies

Enabled incremental data processing

🔹 Analytics Role
Created Customer 360 table

Built KPI tables:

Sales Summary

Product Performance

Customer Segmentation

Churn Analysis

Developed Power BI dashboard

📊 Key Business Outputs
👤 Customer 360 View

💰 Revenue & Sales Trends

🛍️ Product Performance

📈 Customer Segmentation

⚠️ Churn Analysis

🔄 Pipeline Flow
Data is uploaded to AWS S3

Snowpipe loads data into Bronze layer

Streams capture incremental changes

Tasks process data into Silver layer

Further tasks transform data into Gold layer

Power BI consumes Gold layer for dashboards

🧠 Key Features
✅ Batch + Real-time Ingestion

✅ Incremental Processing using Streams

✅ Automated Pipeline using Tasks

✅ Data Quality Handling (Nulls, Duplicates)

✅ Scalable Architecture

✅ Analytics-Ready Data Model
