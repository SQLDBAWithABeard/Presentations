/* Find non-parameterized queries in Query Store */
SELECT count(Pl.plan_id) AS plan_count, Qry.query_hash, Txt.query_text_id, Txt.query_sql_text
FROM sys.query_store_plan AS Pl
INNER JOIN sys.query_store_query AS Qry
    ON Pl.query_id = Qry.query_id
INNER JOIN sys.query_store_query_text AS Txt
    ON Qry.query_text_id = Txt.query_text_id
GROUP BY Qry.query_hash, Txt.query_text_id, Txt.query_sql_text
ORDER BY plan_count desc