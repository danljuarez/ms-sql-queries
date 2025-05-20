-- ***********************************************************************************
-- AUTHOR: Daniel Juarez
-- CREATION DATE: 03/18/2025
-- CODE CHALLENGE: Create a list of employees including ID, name, job title, department, and gender, along with their highest total sales by year and month.
-- Please review how the code has been structured and implemented to follow best practices and improve readability.
-- **************
-- NOTE: To download the 'AdventureWork' MS-SQL sample database, you can refer to the following Microsoft GitHub link:
-- https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks
-- ***********************************************************************************

USE [AdventureWorks]
GO

SELECT 
    sp.BusinessEntityID AS SalesPersonID,
    p.FirstName,
	p.LastName,
	e.JobTitle AS Title,
	d.[Name] AS Department,
	e.Gender,
    YEAR(soh.OrderDate) AS OrderYear,
    MONTH(soh.OrderDate) AS OrderMonth,
    COUNT(soh.SalesOrderID) AS TotalSales
FROM 
	Sales.SalesOrderHeader AS soh
	INNER JOIN 
		Sales.SalesPerson AS sp 
			ON soh.SalesPersonID = sp.BusinessEntityID
    INNER JOIN 
		HumanResources.Employee AS e 
			ON sp.BusinessEntityID = e.BusinessEntityID
    INNER JOIN 
		Person.Person AS p 
			ON e.BusinessEntityID = p.BusinessEntityID
	INNER JOIN 
		HumanResources.EmployeeDepartmentHistory AS edh 
			ON e.BusinessEntityID = edh.BusinessEntityID
			   AND edh.EndDate IS NULL  -- Only current department
	INNER JOIN 
		HumanResources.Department AS d 
			ON edh.DepartmentID = d.DepartmentID
GROUP BY 
    sp.BusinessEntityID,
    p.FirstName,
    p.LastName,
	e.JobTitle,
	d.[Name],
	e.Gender,
    YEAR(soh.OrderDate),
    MONTH(soh.OrderDate)
ORDER BY 
    OrderYear, 
    OrderMonth,
	TotalSales DESC;


-- To verify the accuracy of certain totals, execute the following query:
-- ***********************************************************************************
-- NOTE: Please enter to SQLCMD mode before running this project by choosing 
-- from main menu: Query-> SQLCMD Mode for avoiding error while running script.
-- ***********************************************************************************
/**
-- Declare SalesPersonID variable
:setvar salesPersonId 277
-- Declare orders by year variable
:setvar orderYearDate 2011
-- Declare orders by month variable
:setvar orderMonthDate 10

USE [AdventureWorks]
GO

SELECT COUNT(SalesPersonID) AS [Total Sales]
FROM [AdventureWorks].[Sales].SalesOrderHeader
WHERE SalesPersonID = $(salesPersonId)
  AND YEAR(OrderDate) = $(orderYearDate)
  AND MONTH(OrderDate) = $(orderMonthDate)
**/
