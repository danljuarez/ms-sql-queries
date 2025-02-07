-- ***********************************************************************************
-- AUTHOR: Daniel Juarez
-- CREATION DATE: 07/30/2024
-- DESCRIPTION: Create a table containing a sequence of 60 numbers and identify which of those numbers are Fibonacci numbers.
-- Please take a look at how the code has been structured and implemented, adhering to best practices to improve code readability.
--
-- ********************
-- NOTE: Please enter to SQLCMD mode before running this project by choosing
-- from main menu: Query-> SQLCMD Mode for avoiding error while running script.
-- ***********************************************************************************
SET NOCOUNT ON;
GO
SET NOEXEC OFF;
GO

-- Declare max values for Fibonacci generation
:setvar maxFibValue 60

-- Declare name for a list of numbers table that will be evaluated numbers to determine Fibonacci
:setvar fiboResultTableName "NumberList"

-- Declare database variable name
:setvar DatabaseName "FibonacciDb"

PRINT '';
PRINT 'Calculate and determine Fibonacci numbers from a list of numbers less than $(maxFibValue)';
GO

PRINT '';
PRINT 'Started - ' + CONVERT(varchar, GETDATE(), 121);
GO

IF $(maxFibValue) < 0
	BEGIN
		PRINT '';
		PRINT '*** Error!';
		RAISERROR( '*** MaxFibonacchi Value cannot be less than 0', 20, -1) WITH NOWAIT, LOG;
		SET NOEXEC ON;
	END
GO

USE [master];
GO

-- Drop Database for this sample if already exist
PRINT '';
PRINT '*** Dropping $(DatabaseName) sample database if already exist'
IF EXISTS (SELECT [name] FROM [master].[sys].[databases] WHERE [name] = N'$(DatabaseName)')
   DROP DATABASE $(DatabaseName);
GO

-- If the database has any other open connections close the network connection.
IF @@ERROR = 3702
	BEGIN
	   RAISERROR('$(DatabaseName) database cannot be dropped because there are still other open connections', 127, 127) WITH NOWAIT, LOG;
	   SET NOEXEC ON;
	END
GO

-- Create Database
PRINT '';
PRINT '*** Creating database: $(DatabaseName)';
CREATE DATABASE $(DatabaseName);
GO

/* Check for database if it doesn't exists, do not run the rest of the script */
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = N'$(DatabaseName)')
	BEGIN
		 PRINT '********************************************************************************************************************************************************'
		 + char(10) + '******** $(DatabaseName) Database does not exist. Make sure the script is being run in SQLCMD mode and that variables has been correctly set. **********'
		 + char(10) + '********************************************************************************************************************************************************';
		 SET NOEXEC ON;
	END
GO

PRINT '';
PRINT '*** Drop temporary table for this sample if already exist';
IF OBJECT_ID('tempdb..#FibonacchiValues') IS NOT NULL
	DROP TABLE #FibonacchiValues;
GO

PRINT '';
PRINT '*** Create temporary table for Fibonacci values';
CREATE TABLE #FibonacchiValues (
	Indx INT,
	Vals INT
	UNIQUE NONCLUSTERED (Indx)
);
GO

DECLARE @maxFiboVal INT = $(maxFibValue);
DECLARE @cntr INT = 0;
DECLARE @isNotFiboBase BIT = 'FALSE';
DECLARE @n1 INT;
DECLARE @n2 INT;

PRINT '';
PRINT '*** Assign Fibonacci values';
WHILE @cntr <= @maxFiboVal + 1
	BEGIN
		IF @isNotFiboBase = 'TRUE'
			BEGIN
			   -- Get values for Fibonacci numbers
			   SET @n1 = (SELECT Vals FROM #FibonacchiValues WHERE Indx = (@cntr - 1));
			   SET @n2 = (SELECT Vals FROM #FibonacchiValues WHERE Indx = (@cntr - 2));

			   -- Break loop if Fibonacci number is greater than maxFibValue
			   IF (@n1 + @n2) > @maxFiboVal
				   BREAK;

			   -- Insert Fibonacci number
			   INSERT INTO #FibonacchiValues
					  VALUES (@cntr, (@n1 + @n2));
			END
		ELSE
			BEGIN
			   IF @cntr > @maxFiboVal
				  BREAK;

			   INSERT INTO #FibonacchiValues
					  VALUES (@cntr, @cntr);
			   IF @cntr = 1
				  SET @isNotFiboBase = 'TRUE';
			END
		SET @cntr = @cntr + 1;
	END
GO

USE [$(DatabaseName)];
GO

PRINT '';
PRINT '*** Drop $(fiboResultTableName) table if already exist';
DROP TABLE IF EXISTS [dbo].[$(fiboResultTableName)];
GO

PRINT '';
PRINT '*** Create $(fiboResultTableName) sample table to evaluate';
CREATE TABLE [dbo].[$(fiboResultTableName)](
	[Numbers] [INT] NOT NULL,
	[Fibo Status] [NVARCHAR](100) NULL
) ON [PRIMARY];
GO

PRINT '';
PRINT '*** Add sample numbers to evaluate';
DECLARE @maxFiboVal INT = $(maxFibValue);
DECLARE @cnt INT = 0;

SET @cnt = 0;
WHILE @cnt <= @maxFiboVal
	BEGIN
		INSERT INTO [dbo].[NumberList] (Numbers)
			   VALUES (@cnt);
		SET @cnt = @cnt + 1;
	END
GO

PRINT '';
PRINT '*** Update $(fiboResultTableName) table with label [Is Fibonacci number] when is the case';
UPDATE
	[dbo].[$(fiboResultTableName)]
SET
	[Fibo Status] = '[Is a Fibonacci number]'
	FROM
		[dbo].[$(fiboResultTableName)]
	INNER JOIN
		#FibonacchiValues
	ON ([dbo].[$(fiboResultTableName)].[Numbers] = #FibonacchiValues.Vals)
GO

PRINT '';
PRINT '*** Show the results';
SELECT *
	FROM $(fiboResultTableName)
GO

PRINT '';
PRINT '*** Return SQL to it''s initial state before running this script. ***';
PRINT '*** Drop temporary Database for this sample if exists';
IF OBJECT_ID('tempdb..#FibonacchiValues') IS NOT NULL
	DROP TABLE #FibonacchiValues;
GO

USE [master];
GO

PRINT '';
PRINT '*** Drop sample database $(DatabaseName) if exists';
IF EXISTS (SELECT [name] FROM [master].[sys].[databases] WHERE [name] = N'$(DatabaseName)')
   DROP DATABASE $(DatabaseName);
GO

SET NOEXEC OFF;
GO
