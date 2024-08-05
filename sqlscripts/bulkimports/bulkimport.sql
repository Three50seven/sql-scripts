USE [DATABASE_NAME_HERE]
--NOTE: REPLACE [DATABASE_NAME_HERE] WITH CORRECT DATABASE NAME
--REPLACE table_name WITH CORRECT TABLE TO INSERT BULK DATA

--NOTE: THIS BULK IMPORT TAKES APPROXIMATELY 2-3 HOURS FOR ~69 MILLION RECORDS

--VERIFY WE ARE ON THE CORRECT SERVER:
--select @@SERVERNAME as server_name

/*
--GET THE EXACT NUMBER OF NEW RECORDS BY RUNNING POWERSHELL SCRIPT IN CONTAINING DIRECTORY CONTAINING FILE:
	"X:\project\dataset\table\data_csv.txt" |% {$n = $_; $c = 0; Get-Content -Path $_ -ReadCount 1000 |% { $c += $_.Count }; "$n; $c"}
	
--SUBTRACT 2 FROM RESULTS TO ACCOUNT FOR HEADER AND LAST BLANK ROW DELIMITER

SELECT count(*) FROM table_name 
SELECT (69154550-2) - 69120144 --new records minus old (current) records 
-- 34404 <- DIFFERENCE FROM ABOVE
TRUNCATE TABLE table_name
*/
--GET DATE STAMP OF BULK IMPORT START
DECLARE @current_date datetime 
set @current_date = GETDATE()

PRINT @current_date
GO

--1. BULK INSERT table_name FROM TEXT FILE
BULK INSERT table_name FROM 'X:\sqlscripts\bulkimports\sample_data.txt'
WITH
(
	FORMATFILE = 'X:\sqlscripts\bulkimports\data_format.txt', -- necessary if source file contains double quotes around data
	FIRSTROW = 2,
	--LASTROW = 500000,
	MAXERRORS = 0,
	BATCHSIZE = 1000,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	KEEPNULLS
);
GO

--GET DATE STAMP OF BULK IMPORT END
DECLARE @end_date datetime 
set @end_date = GETDATE()

PRINT @end_date
GO

SELECT count(*) FROM table_name --68431995

--REBUILD THE INDEXES FOR table_name TABLE --This takes about 15-20 minutes to rebuild indexes

USE [DATABASE_NAME_HERE];
GO
ALTER INDEX ALL ON table_name
REBUILD 
GO

