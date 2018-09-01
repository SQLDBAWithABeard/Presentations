USE [ValidationResults]
GO

UPDATE [dbachecks].[Prod_dbachecks_summary]
   SET [TestDate] = GETDATE()
 WHERE SummaryID = 7
GO

UPDATE [dbachecks].[Prod_dbachecks_summary]
   SET [TestDate] = DATEADD(day,-1,GetDAte())
 WHERE SummaryID = 6
GO

UPDATE [dbachecks].[Prod_dbachecks_summary]
   SET [TestDate] = DATEADD(day,-2,GetDAte())
 WHERE SummaryID = 5
 GO
 
UPDATE [dbachecks].[Prod_dbachecks_summary]
   SET [TestDate] = DATEADD(day,-3,GetDAte())
 WHERE SummaryID = 4
 GO
 
UPDATE [dbachecks].[Prod_dbachecks_summary]
   SET [TestDate] = DATEADD(day,-4,GetDAte())
 WHERE SummaryID = 3
 GO

 
UPDATE [dbachecks].[Prod_dbachecks_summary]
   SET [TestDate] = DATEADD(day,-5,GetDAte())
 WHERE SummaryID = 2
 GO

 
UPDATE [dbachecks].[Prod_dbachecks_summary]
   SET [TestDate] = DATEADD(day,-6,GetDAte())
 WHERE SummaryID = 1
 GO

