/*
	Check to see queries that vary by tempdb usage
    Thankyou Erin Stellato
    https://github.com/erinstellato/SQL-Server-Query-Store/blob/master/FindSPQueries_UsingQueryStore.sql
*/
SELECT
	[qst].[query_sql_text],
	[qsq].[query_id], 
	[qsp].[plan_id],
	[qsq].[object_id],
	[rs].[count_executions],
	[rs].[last_execution_time],
	[rs].[avg_duration],
	[rs].[avg_logical_io_reads],
	[rs].[avg_tempdb_space_used],
	[rs].[last_tempdb_space_used],
	[rs].[min_tempdb_space_used],
	[rs].[max_tempdb_space_used],
	[rs].[stdev_tempdb_space_used],
	TRY_CONVERT(XML, [qsp].[query_plan]) AS [QueryPlan_XML]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
ON [qsp].[plan_id] = [rs].[plan_id]
WHERE ([rs].[max_tempdb_space_used] - [rs].[min_tempdb_space_used]) > 1000; 
GO
