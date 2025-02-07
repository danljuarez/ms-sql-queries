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

PRINT '';
PRINT 'Calculate and determine Palindrome string (word, number, phrase or other sequence of symbols that are the same when reverted) from a list of strings provided';
GO

PRINT '';
PRINT 'Started - ' + CONVERT(VARCHAR, GETDATE(), 121);
GO

USE [master];
GO


-- Drop Database for this sample if already exist
PRINT '';
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
PRINT '';
PRINT '*** Creating database: $(DatabaseName)';
CREATE DATABASE $(DatabaseName);
GO

/* Check for database if it doesn't exists, do not run the rest of the script */
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
PRINT '';
PRINT '*** Drop user defined function: $(PalindromeFunc) if already exists';
DROP FUNCTION IF EXISTS [dbo].[$(PalindromeFunc)];
GO

PRINT '';
PRINT '*** Create user defined function: $(PalindromeFunc)';
GO

CREATE FUNCTION [dbo].[$(PalindromeFunc)](@string [NVARCHAR](50))
RETURNS BIT
AS
BEGIN
	DECLARE @wkString NVARCHAR(50) = TRIM(@string);
	DECLARE @stringLength INT = LEN(@wkString);
	DECLARE @revertedString NVARCHAR(50) = '';
	DECLARE @isPalindrome BIT = 'FALSE';

	WHILE @stringLength >= 1
		BEGIN
			SET @revertedString = @revertedString + SUBSTRING(@wkString, @stringLength, 1);

			SET @stringLength = @stringLength - 1;
		END

	IF LOWER(@revertedString) = LOWER(@wkString)
		SET @isPalindrome = 'TRUE';

	RETURN @isPalindrome;
END;
GO

PRINT '';
PRINT '*** Drop $(StringsTableName) table if already exist';
DROP TABLE IF EXISTS [dbo].[$(StringsTableName)]
GO

PRINT '';
PRINT '*** Create $(StringsTableName) sample table to evaluate';
CREATE TABLE [dbo].[$(StringsTableName)](
	[String] [NVARCHAR](50) NOT NULL,
	[Palindrome Status] [NVARCHAR](50) NULL
) ON [PRIMARY];
GO

-- Inserting sample strings
PRINT '';
PRINT '*** Adding sample strings in table $(StringsTableName)';
GO
INSERT [dbo].[$(StringsTableName)](String) VALUES('Finest')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Deified')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Redder')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Keyword')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Humidity')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Interviews')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Mercury')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Racecar')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Example')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Geographical')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Kayak')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Group')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Discovered')
INSERT [dbo].[$(StringsTableName)](String) VALUES('123')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Tenet')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Stream')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Kilometers')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Vision')
INSERT [dbo].[$(StringsTableName)](String) VALUES('[{{[')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Noon')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Interpretation')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Deed')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Mom')
INSERT [dbo].[$(StringsTableName)](String) VALUES('NeverOddOrEven')
INSERT [dbo].[$(StringsTableName)](String) VALUES('TacoCat')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Orchestra')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Nun')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Partnership')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Hospitality')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Wow')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Anna')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Dad')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Increase')
INSERT [dbo].[$(StringsTableName)](String) VALUES('WasItACatISaw')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Rotator')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Madam')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Jeans')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Radar')
INSERT [dbo].[$(StringsTableName)](String) VALUES('12521')
INSERT [dbo].[$(StringsTableName)](String) VALUES('DoGeeseSeeGod')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Repaper')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Diagram')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Acoustic')
INSERT [dbo].[$(StringsTableName)](String) VALUES('People')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Knowledge')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Level')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Civic')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Longitude')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Coupon')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Hannah')
INSERT [dbo].[$(StringsTableName)](String) VALUES('Refer')

GO

-- Determine which strings are Palindrome
PRINT '';
PRINT '*** Update $(StringsTableName) table with label [Is a Palindrome string] when is the case';
UPDATE
	[dbo].[$(StringsTableName)]
SET
	[Palindrome Status] = '[Is a Palindrome string]'
	FROM
		[dbo].[$(StringsTableName)]
	WHERE
		[dbo].[$(PalindromeFunc)]([dbo].[$(StringsTableName)].[String]) = 'TRUE'
GO

PRINT '';
PRINT '*** Show the results';
SELECT *
	FROM [dbo].[$(StringsTableName)]
GO

PRINT '';
PRINT '*** Return SQL to it''s initial state before running this script';
GO

PRINT '';
PRINT '*** Drop user defined function: $(PalindromeFunc) if exists';
DROP FUNCTION IF EXISTS [dbo].[$(PalindromeFunc)];
GO

PRINT '';
PRINT '*** Drop $(StringsTableName) table if exist';
DROP TABLE IF EXISTS [dbo].[$(StringsTableName)]
GO

USE [master];
GO

PRINT '';
PRINT '*** Drop sample database $(DatabaseName) if exists';
IF EXISTS (SELECT [name] FROM [master].[sys].[databases] WHERE [name] = N'$(DatabaseName)')
   DROP DATABASE $(DatabaseName);
GO
