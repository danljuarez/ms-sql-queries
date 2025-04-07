-- ***********************************************************************************
-- AUTHOR: Daniel Juarez
-- CREATION DATE: 07/30/2024
-- DESCRIPTION: Create a table of strings and identify which of those are palindrome symbols.
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

-- Declare database name variable
:setvar DatabaseName "PalindromeDb"

-- Declare variable for name of table that will contain the
-- strings to evaluate
:setvar StringsTableName "StringList"

-- Declare variable for name of user defined function used to
-- determine if a string is Palindrome
:setvar PalindromeFunc "ufnIfPalindromeString"

PRINT 'Calculate and determine Palindrome string (word, number, phrase or other sequence of symbols that are the same when reverted) from a list of strings provided';
GO

PRINT 'Started - ' + CONVERT(VARCHAR, GETDATE(), 121);
GO

USE [master];
GO


-- Drop Database for this sample if already exist
PRINT '*** Dropping $(DatabaseName) sample database if already exist';
IF EXISTS (SELECT [name] FROM [master].[sys].[databases] WHERE [name] = N'$(DatabaseName)')
	DROP DATABASE $(DatabaseName);

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

-- Check for database if it doesn't exists, do not run the rest of the script
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = N'$(DatabaseName)')
	BEGIN
		 PRINT '************************************************************************************************************************************************************'
		 + char(10) + '********   $(DatabaseName) Database does not exist. Make sure the script is being run in SQLCMD mode and the variables has been correctly set.    **********'
		 + char(10) + '************************************************************************************************************************************************************';
		 SET NOEXEC ON;
	END
GO

USE $(DatabaseName);
GO

-- Drop Function if already exists
PRINT '*** Drop user defined function: $(PalindromeFunc) if already exists';
DROP FUNCTION IF EXISTS [dbo].[$(PalindromeFunc)];
GO

PRINT '*** Create user defined function: $(PalindromeFunc)';
GO

CREATE FUNCTION [dbo].[$(PalindromeFunc)](@string [NVARCHAR](50))
RETURNS BIT
AS
BEGIN
    DECLARE @revertedString NVARCHAR(50) = REVERSE(@string);
    RETURN CASE
        WHEN LOWER(@revertedString) = LOWER(@string) THEN 1
        ELSE 0
    END;
END;
GO

PRINT '*** Drop $(StringsTableName) table if already exist';
DROP TABLE IF EXISTS [dbo].[$(StringsTableName)]
GO

PRINT '*** Create $(StringsTableName) sample table to evaluate';
CREATE TABLE [dbo].[$(StringsTableName)](
	[String] [NVARCHAR](50) NOT NULL,
	[Palindrome Status] [NVARCHAR](50) NULL
) ON [PRIMARY];
GO

PRINT '*** Adding sample strings in table $(StringsTableName)';
GO
INSERT [dbo].[$(StringsTableName)]([String])
	VALUES
		('Finest'),
		('Deified'),
		('Redder'),
		('Keyword'),
		('Humidity'),
		('Interviews'),
		('Mercury'),
		('Racecar'),
		('Example'),
		('Geographical'),
		('Kayak'),
		('Group'),
		('Discovered'),
		('123'),
		('Tenet'),
		('Stream'),
		('Kilometers'),
		('Vision'),
		('[{{['),
		('Noon'),
		('Interpretation'),
		('Deed'),
		('Mom'),
		('NeverOddOrEven'),
		('TacoCat'),
		('Orchestra'),
		('Nun'),
		('Partnership'),
		('Hospitality'),
		('Wow'),
		('Anna'),
		('Dad'),
		('Increase'),
		('WasItACatISaw'),
		('Rotator'),
		('Madam'),
		('Jeans'),
		('Radar'),
		('12521'),
		('DoGeeseSeeGod'),
		('Repaper'),
		('Diagram'),
		('Acoustic'),
		('People'),
		('Knowledge'),
		('Level'),
		('Civic'),
		('Longitude'),
		('Coupon'),
		('Hannah'),
		('Refer')

GO

-- Determine which strings are Palindrome
PRINT '*** Update $(StringsTableName) table with label [Is a Palindrome string] when is the case';
UPDATE
	[dbo].[$(StringsTableName)]
SET
	[Palindrome Status] = '[Is a Palindrome string]'
	FROM
		[dbo].[$(StringsTableName)]
	WHERE
		[dbo].[$(PalindromeFunc)]([dbo].[$(StringsTableName)].[String]) = 1
GO

PRINT '*** Show the results';
SELECT *
	FROM [dbo].[$(StringsTableName)]
GO

-- Clean up
PRINT 'Cleaning up...';
PRINT '*** Return SQL to it''s initial state before running this script';
-- Drop sample user defined function if exist
PRINT '*** Drop user defined function: $(PalindromeFunc) if exists';
DROP FUNCTION IF EXISTS [dbo].[$(PalindromeFunc)];
GO

-- Drop sample table if exist
PRINT '*** Drop $(StringsTableName) table if exist';
DROP TABLE IF EXISTS [dbo].[$(StringsTableName)]
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
