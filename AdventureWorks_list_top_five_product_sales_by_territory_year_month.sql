-- ***********************************************************************************
-- AUTHOR: Daniel Juarez
-- DESCRIPTION: Rank the top 5 product sales by year, month, and location.
-- Please review how the code has been structured and implemented to follow best practices and improve readability.
-- **************
-- NOTE: To download the 'AdventureWork' MS-SQL sample database, you can refer to the following Microsoft GitHub link:
-- https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks
-- ***********************************************************************************

USE [AdventureWorks]
GO

-- List all product sales by territory, date, and location
WITH ProductSales AS (
    SELECT
        p.productID,
        p.[Name] AS product_name,
        pm.[Name] AS product_model_name,
        pc.[Name] AS category_name,
        psc.[Name] AS subcategory_name,
        st.[Name] AS sales_territory,
        st.CountryRegionCode AS country,
        YEAR(soh.OrderDate) AS sales_year,
        MONTH(soh.OrderDate) AS sales_month,
        SUM(sod.OrderQty) AS total_quantity_sold
    FROM
        Sales.SalesOrderHeader AS soh
        INNER JOIN
            Sales.SalesOrderDetail AS sod
                ON soh.SalesOrderID = sod.SalesOrderID
        INNER JOIN
            Production.[Product] AS p
                ON sod.ProductID = p.ProductID
        LEFT JOIN
            Production.ProductSubcategory AS psc
                ON p.ProductSubcategoryID = psc.ProductSubcategoryID
        LEFT JOIN
            Production.ProductCategory AS pc
                ON psc.ProductCategoryID = pc.ProductCategoryID
        LEFT JOIN
            Production.ProductModel AS pm
                ON p.ProductModelID = pm.ProductModelID
        INNER JOIN
            Sales.SalesTerritory AS st
                ON soh.TerritoryID = st.TerritoryID
    GROUP BY
        p.productID,
        p.[Name],
        pm.[Name],
        pc.[Name],
        psc.[Name],
        st.[Name],
        st.CountryRegionCode,
        YEAR(soh.OrderDate),
        MONTH(soh.OrderDate)
),

-- Rank each product within its territory and period
RankedSales AS (
    SELECT
        ps.*,
        ROW_NUMBER() OVER (
            PARTITION BY sales_territory, country, sales_year, sales_month
                ORDER BY total_quantity_sold DESC
        ) AS product_rank
    FROM
        ProductSales AS ps
)

-- Return only top 5 products per year, month, territory, and country
SELECT
    productID AS ProductID,
    product_name AS [Product],
    product_model_name AS Model,
    category_name AS Category,
    subcategory_name AS [Sub Category],
    sales_territory AS [Sales Territory],
    country AS Country,
    sales_year AS [Sales Year],
    DATENAME(MONTH, DATEFROMPARTS(sales_year, sales_month, 1)) AS [Sales Month],
    total_quantity_sold AS [Total Quantity Sold]
FROM
    RankedSales
WHERE
    product_rank <= 5
ORDER BY
    sales_year,
    sales_month,
    sales_territory,
    country,
    total_quantity_sold DESC;
