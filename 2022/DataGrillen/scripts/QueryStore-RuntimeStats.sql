/*
	Look at runtime stats for each query in the SP
    Thankyou Erin Stellato
    https://github.com/erinstellato/SQL-Server-Query-Store/blob/master/FindSPQueries_UsingQueryStore.sql
*/
SELECT
    [qsq].[query_id],
    [qsp].[plan_id],
    [qsq].[object_id],
    [rs].[runtime_stats_interval_id],
    [rsi].[start_time],
    [rsi].[end_time],
    [rs].[count_executions],
    [rs].[avg_duration],
    [rs].[avg_cpu_time],
    [rs].[avg_logical_io_reads],
    [rs].[avg_rowcount],
    [qst].[query_sql_text],
    ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
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
ORDER BY [qsq].[query_id], [qsp].[plan_id], [rs].[runtime_stats_interval_id];
GO
