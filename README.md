# 🚀 E-Commerce Order Analytics ETL Pipeline

## 📌 Project Overview

This project demonstrates an end-to-end **ETL pipeline implementation using Medallion Architecture (Bronze → Silver → Gold)** for an e-commerce analytics use case using **Snowflake SQL**.

The pipeline ingests raw transactional data from multiple source systems, applies data quality and transformation logic, implements **Slowly Changing Dimension (SCD Type 2)** handling, and generates business-ready KPI tables for reporting and analytics.

The project simulates real-world data engineering challenges such as:

* Incremental data loading
* Idempotent pipeline execution
* Data cleansing and validation
* SCD Type 2 historical tracking
* Late-arriving data handling
* Aggregated analytics reporting

---

# 🏗️ Architecture

```text
                    SOURCE SYSTEMS
     ┌─────────────────────────────────────┐
     │ Orders │ Customers │ Products │ Items │
     └─────────────────────────────────────┘
                         │
                         ▼
                🥉 BRONZE LAYER
          Raw ingestion + audit tracking
                         │
                         ▼
                🥈 SILVER LAYER
        Cleansing + SCD Type 2 + validation
                         │
                         ▼
                  🥇 GOLD LAYER
             Business KPI aggregations
```

---

# 🎯 Business Problem

The business lacked a centralized analytics layer for monitoring:

* Daily sales performance
* Customer behavior trends
* Product profitability
* Customer lifetime value
* Segment-based business insights

Operational data was distributed across multiple systems with inconsistent formats and no historical tracking.

This project solves that by building a scalable analytics pipeline following modern data engineering practices using Snowflake.

---

# 🧰 Tech Stack

| Component            | Technology    |
| -------------------- | ------------- |
| Cloud Data Warehouse | Snowflake     |
| Query Language       | SQL           |
| Data Modeling        | Snowflake SQL |
| Data Transformation  | SQL           |
| Version Control      | Git & GitHub  |

---

# 📂 Project Structure

```text
project/
│
├── sql/
│   ├── bronze/
│   ├── silver/
│   └── gold/
│
├── source_data/
│
├── screenshots/
│
├── README.md
│
└── documentation/
```

---

# 📊 Source Systems

The pipeline processes data from four source systems:

| Source Table         | Description          |
| -------------------- | -------------------- |
| `orders_source`      | Customer orders      |
| `customers_source`   | Customer master data |
| `products_source`    | Product catalog      |
| `order_items_source` | Order line items     |

---

# 🥉 Bronze Layer

## Purpose

Store raw ingested data exactly as received from source systems.

## Key Features

* Incremental ingestion
* Idempotent loads
* Audit tracking
* Duplicate prevention
* Watermark-based processing

## Bronze Tables

* `bronze_orders`
* `bronze_customers`
* `bronze_products`
* `bronze_order_items`

## Audit Columns Added

* `ingestion_timestamp`
* `source_file`
* `row_hash`

---

# 🥈 Silver Layer

## Purpose

Create cleansed and analytics-ready datasets.

## Key Features

* Data quality validation
* Referential integrity checks
* Deduplication
* SCD Type 2 implementation
* Business rule transformations

---

## 🔄 SCD Type 2 Implementation

Implemented historical tracking for:

### Customers

Tracked changes:

* Email
* City
* Country
* Customer Segment

### Products

Tracked changes:

* Price
* Cost
* Category

### SCD Columns

* `effective_from_date`
* `effective_to_date`
* `is_current`
* `row_hash`

---

# 🥇 Gold Layer

## Purpose

Generate business KPIs and aggregated reporting tables.

## Gold Tables

### `gold_daily_sales_summary`

Tracks:

* Daily revenue
* Orders
* Units sold
* Cancellation rates

### `gold_customer_lifetime_value`

Tracks:

* Customer revenue
* Profitability
* Active status
* Order history

### `gold_product_performance`

Tracks:

* Product revenue
* Profit margin
* Units sold
* Product rankings

### `gold_customer_segment_trends`

Tracks:

* Customer growth
* Churn
* Segment revenue trends

---

# 📈 Key Data Engineering Concepts Demonstrated

✅ Medallion Architecture
✅ Incremental ETL Pipelines
✅ SCD Type 2
✅ Data Quality Checks
✅ Idempotent Processing
✅ Data Lineage
✅ Watermarking
✅ Aggregation Pipelines
✅ Referential Integrity
✅ Late Arriving Data Handling

---

# 🧪 Data Quality Rules

Implemented multiple validation and cleansing rules:

* Invalid order statuses mapped to `UNKNOWN`
* Negative amounts filtered
* NULL payment methods standardized
* Duplicate records removed
* Foreign key validation enforced

---

# 🔁 Incremental Loading Strategy

The pipeline supports daily incremental ingestion using:

* Watermark tracking
* Hash-based deduplication
* Change detection logic
* Re-runnable ETL execution

This ensures:

* No duplicate processing
* Faster execution
* Reliable pipeline recovery

---

# 📌 Sample Business KPIs

The Gold Layer enables analytics such as:

* Daily Sales Revenue
* Average Order Value
* Customer Lifetime Value (CLV)
* Product Profitability
* Customer Churn Trends
* Revenue by Customer Segment
* Cancellation Analysis

---

# 🚀 How to Run the Project

## 1️⃣ Clone Repository

```bash
git clone https://github.com/your-username/ecommerce-etl-pipeline.git
cd ecommerce-etl-pipeline
```

---

## 2️⃣ Configure Snowflake Environment

* Create a Snowflake database and schemas for Bronze, Silver, and Gold layers
* Upload source data files into Snowflake stages
* Configure warehouse and roles

---

## 3️⃣ Execute SQL Scripts

Run SQL scripts in the following order:

```sql
-- Bronze Layer
1.cresting stage.sql
# 🚀 E-Commerce Order Analytics ETL Pipeline

## 📌 Project Overview

This project demonstrates an end-to-end **ETL pipeline implementation using Medallion Architecture (Bronze → Silver → Gold)** for an e-commerce analytics use case using **Snowflake SQL**.

The pipeline ingests raw transactional data from multiple source systems, applies data quality and transformation logic, implements **Slowly Changing Dimension (SCD Type 2)** handling, and generates business-ready KPI tables for reporting and analytics.

The project simulates real-world data engineering challenges such as:

* Incremental data loading
* Idempotent pipeline execution
* Data cleansing and validation
* SCD Type 2 historical tracking
* Late-arriving data handling
* Aggregated analytics reporting

---

# 🏗️ Architecture

```text
                    SOURCE SYSTEMS
     ┌─────────────────────────────────────┐
     │ Orders │ Customers │ Products │ Items │
     └─────────────────────────────────────┘
                         │
                         ▼
                🥉 BRONZE LAYER
          Raw ingestion + audit tracking
                         │
                         ▼
                🥈 SILVER LAYER
        Cleansing + SCD Type 2 + validation
                         │
                         ▼
                  🥇 GOLD LAYER
             Business KPI aggregations
```

---

# 🎯 Business Problem

The business lacked a centralized analytics layer for monitoring:

* Daily sales performance
* Customer behavior trends
* Product profitability
* Customer lifetime value
* Segment-based business insights

Operational data was distributed across multiple systems with inconsistent formats and no historical tracking.

This project solves that by building a scalable analytics pipeline following modern data engineering practices using Snowflake.

---

# 🧰 Tech Stack

| Component            | Technology    |
| -------------------- | ------------- |
| Cloud Data Warehouse | Snowflake     |
| Query Language       | SQL           |
| Data Modeling        | Snowflake SQL |
| Data Transformation  | SQL           |
| Version Control      | Git & GitHub  |

---

# 📂 Project Structure

```text
project/
│
├── sql/
│   ├── bronze/
│   ├── silver/
│   └── gold/
│
├── source_data/
│
├── screenshots/
│
├── README.md
│
└── documentation/
```

---

# 📊 Source Systems

The pipeline processes data from four source systems:

| Source Table         | Description          |
| -------------------- | -------------------- |
| `orders_source`      | Customer orders      |
| `customers_source`   | Customer master data |
| `products_source`    | Product catalog      |
| `order_items_source` | Order line items     |

---

# 🥉 Bronze Layer

## Purpose

Store raw ingested data exactly as received from source systems.

## Key Features

* Incremental ingestion
* Idempotent loads
* Audit tracking
* Duplicate prevention
* Watermark-based processing

## Bronze Tables

* `bronze_orders`
* `bronze_customers`
* `bronze_products`
* `bronze_order_items`

## Audit Columns Added

* `ingestion_timestamp`
* `source_file`
* `row_hash`

---

# 🥈 Silver Layer

## Purpose

Create cleansed and analytics-ready datasets.

## Key Features

* Data quality validation
* Referential integrity checks
* Deduplication
* SCD Type 2 implementation
* Business rule transformations

---

## 🔄 SCD Type 2 Implementation

Implemented historical tracking for:

### Customers

Tracked changes:

* Email
* City
* Country
* Customer Segment

### Products

Tracked changes:

* Price
* Cost
* Category

### SCD Columns

* `effective_from_date`
* `effective_to_date`
* `is_current`
* `row_hash`

---

# 🥇 Gold Layer

## Purpose

Generate business KPIs and aggregated reporting tables.

## Gold Tables

### `gold_daily_sales_summary`

Tracks:

* Daily revenue
* Orders
* Units sold
* Cancellation rates

### `gold_customer_lifetime_value`

Tracks:

* Customer revenue
* Profitability
* Active status
* Order history

### `gold_product_performance`

Tracks:

* Product revenue
* Profit margin
* Units sold
* Product rankings

### `gold_customer_segment_trends`

Tracks:

* Customer growth
* Churn
* Segment revenue trends

---

# 📈 Key Data Engineering Concepts Demonstrated

✅ Medallion Architecture
✅ Incremental ETL Pipelines
✅ SCD Type 2
✅ Data Quality Checks
✅ Idempotent Processing
✅ Data Lineage
✅ Watermarking
✅ Aggregation Pipelines
✅ Referential Integrity
✅ Late Arriving Data Handling

---

# 🧪 Data Quality Rules

Implemented multiple validation and cleansing rules:

* Invalid order statuses mapped to `UNKNOWN`
* Negative amounts filtered
* NULL payment methods standardized
* Duplicate records removed
* Foreign key validation enforced

---

# 🔁 Incremental Loading Strategy

The pipeline supports daily incremental ingestion using:

* Watermark tracking
* Hash-based deduplication
* Change detection logic
* Re-runnable ETL execution

This ensures:

* No duplicate processing
* Faster execution
* Reliable pipeline recovery

---

# 📌 Sample Business KPIs

The Gold Layer enables analytics such as:

* Daily Sales Revenue
* Average Order Value
* Customer Lifetime Value (CLV)
* Product Profitability
* Customer Churn Trends
* Revenue by Customer Segment
* Cancellation Analysis

---

# 🚀 How to Run the Project

## 1️⃣ Clone Repository

```bash
git clone https://github.com/your-username/ecommerce-etl-pipeline.git
cd ecommerce-etl-pipeline
```

---

## 2️⃣ Configure Snowflake Environment

* Create a Snowflake database and schemas for Bronze, Silver, and Gold layers
* Upload source data files into Snowflake stages
* Configure warehouse and roles

---

## 3️⃣ Execute SQL Scripts

Run SQL scripts in the following order:

```sql
-- Bronze Layer
1.Creating stage.sql
2.File Format.sql
3.Bronze layer creation.sql
4.Bronze Ingestion.sql

-- Silver Layer
5.Silver layer creation.sql
6.Silver layer ingestion.sql

-- Gold Layer
7.gold layer creation.sql
8.aggregation.sql

```

---

# ✅ Testing

Implemented:

* Data validation checks
* Incremental load validation
* SCD Type 2 validation
* Deduplication checks
* Referential integrity validation

---

# 📷 Suggested GitHub Screenshots

Add screenshots for:

* Snowflake worksheets
* Bronze/Silver/Gold tables
* SCD Type 2 history examples
* KPI query outputs
* Query execution results

---

# 📚 Learning Outcomes

Through this project, I gained hands-on experience in:

* Building production-style ETL pipelines in Snowflake
* Designing Medallion Architecture
* Implementing SCD Type 2 using SQL
* Data modeling and warehousing
* Incremental processing strategies
* Writing scalable SQL transformations
* Applying data quality frameworks

---

# 🔮 Future Improvements

Potential enhancements:

* Snowflake Tasks & Streams automation
* dbt integration
* Real-time ingestion pipelines
* Dashboard integration (Power BI/Tableau)
* Cloud orchestration with Airflow
* Advanced monitoring and alerting

---

# 👨‍💻 Author

**Your Name**

Data Analyst | Data Engineer | SQL Developer

* LinkedIn: https://linkedin.com/in/your-profile
* GitHub: https://github.com/your-username

---

# ⭐ If You Found This Project Useful

Please consider giving this repository a ⭐ on GitHub.
.sql
bronze_products.sql
bronze_order_items.sql

-- Silver Layer
silver_customers.sql
silver_products.sql
silver_orders.sql

-- Gold Layer
gold_daily_sales_summary.sql
gold_customer_lifetime_value.sql
gold_product_performance.sql
gold_customer_segment_trends.sql
```

---

# ✅ Testing

Implemented:

* Data validation checks
* Incremental load validation
* SCD Type 2 validation
* Deduplication checks
* Referential integrity validation

---

# 📷 Suggested GitHub Screenshots

Add screenshots for:

* Snowflake worksheets
* Bronze/Silver/Gold tables
* SCD Type 2 history examples
* KPI query outputs
* Query execution results

---

# 📚 Learning Outcomes

Through this project, I gained hands-on experience in:

* Building production-style ETL pipelines in Snowflake
* Designing Medallion Architecture
* Implementing SCD Type 2 using SQL
* Data modeling and warehousing
* Incremental processing strategies
* Writing scalable SQL transformations
* Applying data quality frameworks

---

# 🔮 Future Improvements

Potential enhancements:

* Snowflake Tasks & Streams automation
* dbt integration
* Real-time ingestion pipelines
* Dashboard integration (Power BI/Tableau)
* Cloud orchestration with Airflow
* Advanced monitoring and alerting

---

# 👨‍💻 Author

**Your Name**

Data Analyst | Data Engineer | SQL Developer

* LinkedIn: https://linkedin.com/in/your-profile
* GitHub: https://github.com/your-username

---

# ⭐ If You Found This Project Useful

Please consider giving this repository a ⭐ on GitHub.
