/*
	Created by THEBEARD\enterpriseadmin using dbatools Export-DbaScript for objects on sql0 at 05/08/2018 15:37:40
	See https://dbatools.io/Export-DbaScript for more information
*/
EXEC master.dbo.sp_addlinkedserver @server = N'bearddockerhost,15786', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'bearddockerhost,15786',@useself=N'False',@locallogin=NULL,@rmtuser=N'sa',@rmtpassword='########'

EXEC master.dbo.sp_serveroption @server=N'bearddockerhost,15786', @optname=N'collation compatible', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'bearddockerhost,15786', @optname=N'data access', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=N'bearddockerhost,15786', @optname=N'dist', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'bearddockerhost,15786', @optname=N'pub', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'bearddockerhost,15786', @optname=N'rpc', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=N'bearddockerhost,15786', @optname=N'rpc out', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=N'bearddockerhost,15786', @optname=N'sub', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'bearddockerhost,15786', @optname=N'connect timeout', @optvalue=N'0'
EXEC master.dbo.sp_serveroption @server=N'bearddockerhost,15786', @optname=N'collation name', @optvalue=null
EXEC master.dbo.sp_serveroption @server=N'bearddockerhost,15786', @optname=N'lazy schema validation', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=N'bearddockerhost,15786', @optname=N'query timeout', @optvalue=N'0'
EXEC master.dbo.sp_serveroption @server=N'bearddockerhost,15786', @optname=N'use remote collation', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=N'bearddockerhost,15786', @optname=N'remote proc transaction promotion', @optvalue=N'true'
