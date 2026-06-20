# azure-ecommerce-data-pipeline

# Azure End-to-End E-Commerce Data Pipeline

An end-to-end cloud data engineering pipeline built on Azure, ingesting, transforming, and analyzing the Brazilian E-Commerce (Olist) dataset using a Medallion Architecture (Bronze → Silver → Gold).

The pipeline covers ingestion, transformation, data quality validation, serving, and visualization — using Azure Data Factory, Azure Databricks (Unity Catalog), Azure Synapse Analytics, and Power BI.

## Architecture

```
GitHub (raw CSV) 
   → Azure Data Factory (parameterized, metadata-driven pipeline)
   → ADLS Gen2 (Bronze)
   → Azure Databricks + PySpark (Unity Catalog External Locations)
   → ADLS Gen2 (Silver – cleaned, deduplicated)
   → Azure Databricks (aggregations + data quality checks)
   → ADLS Gen2 (Gold – business-ready Delta tables)
   → Azure Synapse Analytics (Serverless SQL views)
   → Power BI (dashboard)
```

## Tech Stack

| Layer | Tool |
|---|---|
| Orchestration / Ingestion | Azure Data Factory |
| Storage | Azure Data Lake Storage Gen2 |
| Transformation | Azure Databricks (PySpark, Delta Lake) |
| Governance | Unity Catalog (External Locations, Storage Credentials, Access Connector) |
| Serving Layer | Azure Synapse Analytics (Serverless SQL) |
| Visualization | Power BI |
| Source Data | [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) |

## Dataset

~100K orders (2016–2018) across 9 relational tables — orders, customers, order items, payments, reviews, products, sellers, geolocation, and category translations.

## What This Pipeline Does

### 1. Ingestion — Azure Data Factory
- Built a **metadata-driven, parameterized pipeline** using a `ForEach` activity and a pipeline-level array parameter (`file_list`) instead of duplicating pipelines per file.
- A single parameterized HTTP dataset and a single parameterized ADLS sink dataset dynamically handle all 8 source files using `@item()` and `@dataset().file_name`.
- Source: raw CSVs hosted on GitHub. Sink: ADLS Gen2 Bronze container.

### 2. Transformation — Azure Databricks
- **`bronze_to_silver`**: reads raw CSVs from Bronze, removes duplicates and null keys, writes cleaned data to Silver as Delta tables.
- **`silver_to_gold`**: joins and aggregates Silver tables into business-ready Gold tables — monthly revenue, category-level sales, and customer order counts.
- **`data_quality_checks`**: profiles each table for row counts, null keys, and duplicate keys, and writes the results to a dedicated `data_quality_summary` Delta table in Gold.
- Storage access is handled via **Unity Catalog External Locations** backed by an **Azure Databricks Access Connector** (managed identity) — no account keys or secrets hardcoded in notebooks.

### 3. Serving — Azure Synapse Analytics
- Serverless SQL views created directly over the Gold Delta tables using `OPENROWSET ... FORMAT = 'DELTA'`, with zero data movement or duplication.
- Views: `monthly_revenue`, `category_sales`, `customer_order_counts`, `data_quality_summary`.

### 4. Visualization — Power BI
- Connected directly to the Synapse Serverless SQL endpoint.
- Dashboard covers revenue trends, top-performing product categories, customer order behavior, and a dedicated data quality view.

![Power BI Dashboard](powerbi/dashboard_screenshot.png)

## Repository Structure

```
azure-ecommerce-data-pipeline/
├── adf_pipelines/
│   ├── pipeline1.json
│   ├── ds_bronze_orders.json
│   ├── ds_http_orders.json
│   └── linked_services/
├── databricks_notebooks/
│   ├── bronze_to_silver.py
│   ├── silver_to_gold.py
│   └── data_quality_checks.py
├── synapse_sql/
│   └── create_views.sql
├── powerbi/
│   └── dashboard_screenshot.png
├── architecture_diagram.png
└── README.md
```

## Key Engineering Decisions

- **Parameterized ADF pipeline over per-file pipelines** — avoids duplicated pipeline logic, scales to new source files by editing a single array parameter.
- **Unity Catalog over storage account keys** — credential-less, secure access pattern between Databricks and ADLS Gen2 using a managed identity (Access Connector), matching how production environments are typically secured.
- **Medallion Architecture (Bronze/Silver/Gold)** — clear separation between raw, cleaned, and business-ready data, with each layer independently reproducible.
- **Built-in data quality layer** — null and duplicate checks are tracked as a first-class Gold table rather than ad-hoc validation, surfaced directly in the Power BI dashboard.
- **Serverless-first compute** — Databricks Serverless and Synapse Serverless SQL were used throughout to keep the project cost-efficient on a student Azure subscription, with no idle compute charges.

## Getting Started (Reproducing This Project)

1. Upload the Olist dataset CSVs to a public GitHub repo (or your own).
2. Deploy an ADLS Gen2 account with `bronze`, `silver`, and `gold` containers.
3. Import the ADF pipeline JSON from `adf_pipelines/`, update the linked service URLs to point to your storage account and GitHub repo.
4. Set up a Unity Catalog Storage Credential + External Locations in Databricks, pointing to your storage account.
5. Run the notebooks in `databricks_notebooks/` in order: `bronze_to_silver` → `silver_to_gold` → `data_quality_checks`.
6. Run `synapse_sql/create_views.sql` in a Synapse Serverless SQL script against your Gold container.
7. Connect Power BI Desktop to your Synapse Serverless SQL endpoint and load the views.

## Author

**Keerthana L R**
[GitHub](https://github.com/keerthana-lr) · [LinkedIn](https://linkedin.com/in/contactkeerthanalr) · lr.keerthanaravi@gmail.com
