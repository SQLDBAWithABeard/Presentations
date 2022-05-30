/* paramataerized queries*/
SELECT qsq.query_id, qsqt.query_sql_text
FROM sys.query_store_query AS qsq 
INNER JOIN sys.query_store_query_text AS qsqt
ON qsq.query_text_id= qsqt.query_text_id 
WHERE qsq.query_parameterization_type<>0 or qsqt.query_sql_text like '%@%';

/*non-paramataerized queries*/
SELECT qsq.query_id, qsqt.query_sql_text
FROM sys.query_store_query AS qsq 
INNER JOIN sys.query_store_query_text AS qsqt
ON qsq.query_text_id= qsqt.query_text_id 
WHERE query_parameterization_type=0;