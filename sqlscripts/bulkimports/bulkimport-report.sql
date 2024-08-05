--NOTE: REPLACE [DATABASE_NAME_HERE] WITH CORRECT DATABASE NAME
--REPLACE table_name WITH CORRECT TABLE TO INSERT BULK DATA

USE [DATABASE_NAME_HERE]
GO

--BULK INSERT REPORT
declare @time_executed_mins as float
		,@total_trgt_records as float
		,@total_current_count as float
		,@records_per_minute as float
		,@percentage_complete as float
		,@remaining_time_mins as float
		,@remaining_records as float
		,@start_date as datetime
		,@current_date as datetime
		,@quarter_goal as varchar(100)


/*
--GET THE EXACT NUMBER OF NEW RECORDS BY RUNNING POWERSHELL SCRIPT IN CONTAINING DIRECTORY CONTAINING FILE:
	"X:\sqlscripts\bulkimports\sample_data.txt" |% {$n = $_; $c = 0; Get-Content -Path $_ -ReadCount 1000 |% { $c += $_.Count }; "$n; $c"}
*/

set @total_trgt_records = 69154550-2 --manually update this to match the expected record count when complete (subtract 2 for header and terminating-row)
set @start_date = 'Aug  5 2024  3:18PM' --manually update this to match execution start time of bulk insert
set @current_date = GETDATE()
set @time_executed_mins = cast(DATEDIFF( MI , @start_date , @current_date ) as float)--67 
set @total_current_count = (select COUNT(*) from table_name)
set @records_per_minute =  case when @time_executed_mins <= 0 THEN 0 ELSE @total_current_count/@time_executed_mins END
set @percentage_complete = cast(((@total_current_count/@total_trgt_records) * 100) as float)
set @remaining_records = @total_trgt_records - @total_current_count
set @remaining_time_mins = case when @records_per_minute <= 0 THEN 0 ELSE @remaining_records/@records_per_minute END
set @quarter_goal = REPLICATE(REPLICATE('|', 24) + ':',4)

select @total_current_count as CurrentRecordsProcessed
	,@time_executed_mins as TimeSpentExecuting_InMins
	,@remaining_records as RecordsRemaining
	,convert(varchar(100),convert(decimal(12,2),@percentage_complete)) + '%' as PercentageComplete	
	,convert(decimal(12,2),@records_per_minute) as RecordsPerMin
	,convert(decimal(12,0),@remaining_time_mins) as EstTimeRemaining_InMinutes
	,convert(decimal(12,2),CAST((@remaining_time_mins/60) as float)) as EstTimeRemaining_InHrs
	,@current_date as [TimeStamp]

--SHOW COMPLETE PERCENTAGE GRAPHIC
select REPLICATE('|', FLOOR(@percentage_complete)) as PercentageCompleteGraphic_________END, 'CURRENT - PROGRESS' as notes, 1 as ordering
UNION
select  REPLICATE('|', 100) as PercentageCompleteGraphic_________END, 'GOAL' as notes, 3 as ordering
UNION
select  LEFT(@quarter_goal,DATALENGTH(@quarter_goal)-1) as PercentageCompleteGraphic_________END, 'GOAL - QUARTERS' as notes, 2 as ordering
ORDER BY ordering

/*
RESULTS SAMPLE:
CurrentRecordsProcessed	TimeSpentExecuting_InMins	RecordsRemaining	PercentageComplete	RecordsPerMin	EstTimeRemaining_InMinutes	EstTimeRemaining_InHrs	TimeStamp
2861999	3	65846139	4.17%	953999.67	69	1.15	2022-07-06 15:16:34.623

PercentageCompleteGraphic_________END	notes	ordering
||||	CURRENT - PROGRESS	1
||||||||||||||||||||||||:||||||||||||||||||||||||:||||||||||||||||||||||||:|||||||||||||||||||||||||	GOAL - QUARTERS	2
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	GOAL	3
*/