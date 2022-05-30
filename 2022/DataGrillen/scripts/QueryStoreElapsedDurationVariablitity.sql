/*
	Variability for Duration
    Thankyou Erin Stellato
    https://github.com/erinstellato/SQL-Server-Query-Store/blob/master/FindSPQueries_UsingQueryStore.sql
*/
SELECT 
	t.text, 
	qs.execution_count, 
	qs.min_logical_reads, 
	qs.max_logical_reads, 
	qs.min_elapsed_time, 
	qs.max_elapsed_time, 
	qs.min_worker_time, 
	qs.max_worker_time, 
    (qs.max_elapsed_time - qs.min_elapsed_time) AS Elapsed_Difference,
	qp.query_plan
FROM sys.dm_exec_query_stats AS qs 
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS t
ORDER BY (qs.max_elapsed_time - qs.min_elapsed_time) DESC
-- WHERE (qs.max_elapsed_time - qs.min_elapsed_time) > 10000;
GO
