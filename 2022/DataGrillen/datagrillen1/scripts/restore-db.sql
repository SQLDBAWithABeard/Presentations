USE [master]
RESTORE DATABASE [AdventureWorks] FROM  DISK = N'/tmp/AdventureWorks2017.bak'  WITH MOVE 'AdventureWorks2017' TO '/var/opt/mssql/data/AdventureWorks2019.mdf', MOVE 'AdventureWorks2017_Log' TO '/var/opt/mssql/data/AdventureWorks2019_Log.ldf'
GO
ALTER DATABASE [AdventureWorks] SET COMPATIBILITY_LEVEL = 150
ALTER DATABASE [AdventureWorks] SET QUERY_STORE = ON;
