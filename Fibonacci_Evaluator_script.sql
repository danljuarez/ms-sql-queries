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

PRINT '*** Resetting SQL environment ***';
SET NOEXEC OFF;
GO

-- Declare max values for Fibonacci generation
:setvar maxFibonacciValue 60

-- Declare name for a list of numbers table that will be evaluated numbers to determine Fibonacci
:setvar FibonacciResults "NumberList"

-- Declare database variable name
:setvar DatabaseName "FibonacciDb"

PRINT 'Calculate and determine Fibonacci numbers from a list of numbers less than $(maxFibonacciValue)';
GO

PRINT 'Started - ' + CONVERT(varchar, GETDATE(), 121);
GO

IF $(maxFibonacciValue) < 0
	BEGIN
		PRINT '';
		PRINT '*** Error!';
		RAISERROR( '*** MaxFibonacci Value cannot be less than 0', 20, -1) WITH NOWAIT, LOG;
		SET NOEXEC ON;
	END
GO

USE [master];
GO

-- Drop Database for this sample if already exist
PRINT '*** Dropping $(DatabaseName) sample database if already exist';
IF EXISTS (SELECT [name] FROM [master].[sys].[databases] WHERE [name] = N'$(DatabaseName)')
	BEGIN
		DROP DATABASE $(DatabaseName);
		PRINT '*** Database $(DatabaseName) dropped successfully.';
	END
ELSE
	BEGIN
		PRINT '*** Database $(DatabaseName) does not exist.';
	END
GO

-- If the database has any other open connections close the network connection.
IF @@ERROR = 3702
	BEGIN
	   RAISERROR('$(DatabaseName) database cannot be dropped because there are still other open connections', 127, 127) WITH NOWAIT, LOG;
	   SET NOEXEC ON;
	END
GO

-- Create Database
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

-- Drop temporary table for this sample if already exist
IF OBJECT_ID('tempdb..#FibonacciValues') IS NOT NULL
	BEGIN
		DROP TABLE #FibonacciValues;
		PRINT '*** Temporary table #FibonacciValues dropped successfully.';
	END
GO

PRINT '*** Create temporary table for Fibonacci values';
CREATE TABLE #FibonacciValues (
	Indx INT,
	Vals INT
	UNIQUE NONCLUSTERED (Indx)
);
GO

DECLARE @maxFibonacciValue INT = $(maxFibonacciValue);
DECLARE @cntr INT = 0;
DECLARE @n1 INT;
DECLARE @n2 INT;

PRINT '*** Assign Fibonacci values';
WHILE @cntr <= @maxFibonacciValue + 1
	BEGIN
		IF @cntr <= 1
			BEGIN
				INSERT INTO #FibonacciValues (Indx, Vals)
					   VALUES (@cntr, @cntr);
			END
		ELSE
			BEGIN
				SET @n1 = (SELECT Vals FROM #FibonacciValues WHERE Indx = (@cntr - 1));
				SET @n2 = (SELECT Vals FROM #FibonacciValues WHERE Indx = (@cntr - 2));

				IF (@n1 + @n2) > @maxFibonacciValue
					BREAK;

				INSERT INTO #FibonacciValues (Indx, Vals)
					   VALUES (@cntr, (@n1 + @n2));
			END

		SET @cntr = @cntr + 1;
	END
GO

USE [$(DatabaseName)];
GO

PRINT '*** Drop $(FibonacciResults) table if already exist';
DROP TABLE IF EXISTS [dbo].[$(FibonacciResults)];
GO

PRINT '*** Create $(FibonacciResults) table to store Fibonacci results';
CREATE TABLE [dbo].[$(FibonacciResults)](
	[Numbers] [INT] NOT NULL,
	[FibonacciStatus] [NVARCHAR](100) NULL
) ON [PRIMARY];
GO

-- Add sample numbers to evaluate
DECLARE @maxFibonacciValue INT = $(maxFibonacciValue);
DECLARE @cnt INT = 0;

PRINT '*** Add sample numbers to evaluate...';
WHILE @cnt <= @maxFibonacciValue
	BEGIN
		INSERT INTO [dbo].[$(FibonacciResults)] ([Numbers])
			   VALUES (@cnt);
		SET @cnt = @cnt + 1;
	END
GO

PRINT '*** Update $(FibonacciResults) table with label [Is Fibonacci number] when is the case';
UPDATE
	[dbo].[$(FibonacciResults)]
SET
	[FibonacciStatus] = '[Is a Fibonacci number]'
	FROM
		[dbo].[$(FibonacciResults)]
	INNER JOIN
		#FibonacciValues
	ON ([dbo].[$(FibonacciResults)].[Numbers] = #FibonacciValues.Vals)
GO

-- Show the results
PRINT '*** Show the results';
SELECT *
	FROM $(FibonacciResults)
GO

-- Clean up
PRINT 'Cleaning up...';
-- Drop temporary database objects
IF OBJECT_ID('tempdb..#FibonacciValues') IS NOT NULL
	BEGIN
		PRINT '*** Dropping temporary table #FibonacchiValues ***';
		DROP TABLE #FibonacciValues;
	END
GO

-- Switch to the master database
USE [master];
GO

-- Drop sample database if it exists
PRINT '*** Drop sample database $(DatabaseName) if exists';
IF EXISTS (SELECT [name] FROM [master].[sys].[databases] WHERE [name] = N'$(DatabaseName)')
	BEGIN
		PRINT '*** Dropping sample database $(DatabaseName) ***';
		DROP DATABASE $(DatabaseName);
	END
GO
