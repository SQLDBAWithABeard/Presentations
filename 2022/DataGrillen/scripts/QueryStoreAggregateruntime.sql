/*
	Check aggregate runtime stats for the SP
    Thankyou Erin Stellato
    https://github.com/erinstellato/SQL-Server-Query-Store/blob/master/FindSPQueries_UsingQueryStore.sql
*/
SELECT
	[qsq].[query_id], 
	[qsp].[plan_id], 
	OBJECT_NAME([qsq].[object_id]) AS [ObjectName], 
	SUM([rs].[count_executions]) AS [TotalExecutions],
	AVG([rs].[avg_duration]) AS [Avg_Duration],
	AVG([rs].[avg_cpu_time]) AS [Avg_CPU],
	AVG([rs].[avg_logical_io_reads]) AS [Avg_LogicalReads],
	MIN([qst].[query_sql_text]) AS[Query]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
	ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'dbo.uspGetEmployeeManagers')
AND [rs].[last_execution_time] > DATEADD(HOUR, -1, GETUTCDATE())  
AND [rs].[execution_type] = 0
GROUP BY [qsq].[query_id], [qsp].[plan_id], OBJECT_NAME([qsq].[object_id])
ORDER BY AVG([rs].[avg_cpu_time]) DESC;