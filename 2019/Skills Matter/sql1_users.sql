/*
	Created by  using dbatools Export-DbaLogin for objects on localhost,15592 at 2019-08-17 10:44:57.012
	See https://dbatools.io/Export-DbaLogin for more information
*/
USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'BUILTIN\Administrators') CREATE LOGIN [BUILTIN\Administrators] FROM WINDOWS WITH DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [BUILTIN\Administrators]
GO

USE master

GO
Grant CONNECT SQL TO [BUILTIN\Administrators]  AS [sa]
GO

USE master

GO
IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = 'sqladmin') CREATE LOGIN [sqladmin] WITH PASSWORD = 0x0200B3B4D9D570987077C7EEB8C45DF5A4D952AA9FD344C9F06F42D942AD74E08940F4348AC6FB6049C134963172E6D8D1AA6E6BDBD6D3026CDCE1BBD656B25F32242C8B5815 HASHED, SID = 0xA8E3DF71C38F0D4088CDDD82F92C6661, DEFAULT_DATABASE = [master], CHECK_POLICY = ON, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [sqladmin]
GO

USE master

GO
Grant CONNECT SQL TO [sqladmin]  AS [sa]
GO
