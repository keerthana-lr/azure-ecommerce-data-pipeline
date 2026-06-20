CREATE DATABASE ecommerce_gold;

CREATE OR ALTER VIEW dbo.monthly_revenue AS
SELECT *
FROM OPENROWSET(
    BULK 'https://stecommercepipeline.dfs.core.windows.net/gold/monthly_revenue/',
    FORMAT = 'DELTA'
) AS result;


CREATE OR ALTER VIEW dbo.category_sales AS
SELECT *
FROM OPENROWSET(
    BULK 'https://stecommercepipeline.dfs.core.windows.net/gold/category_sales/',
    FORMAT = 'DELTA'
) AS result;

CREATE OR ALTER VIEW dbo.customer_order_counts AS
SELECT *
FROM OPENROWSET(
    BULK 'https://stecommercepipeline.dfs.core.windows.net/gold/customer_order_counts/',
    FORMAT = 'DELTA'
) AS result;

CREATE OR ALTER VIEW dbo.data_quality_summary AS
SELECT *
FROM OPENROWSET(
    BULK 'https://stecommercepipeline.dfs.core.windows.net/gold/data_quality_summary/',
    FORMAT = 'DELTA'
) AS result;


SELECT * FROM dbo.monthly_revenue;