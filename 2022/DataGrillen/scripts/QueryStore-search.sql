/*
	Check to see what queries exist for the SP
    Thankyou Erin Stellato
    https://github.com/erinstellato/SQL-Server-Query-Store/blob/master/FindSPQueries_UsingQueryStore.sql
*/
SELECT
	[qsq].[query_id], 
	[qsp].[plan_id], 
	[qsq].[object_id], 
	[qst].[query_sql_text], 
	ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'dbo.uspGetEmployeeManagers');
GO