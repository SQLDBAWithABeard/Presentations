DECLARE @PrincipalName VARCHAR(250) = ''
DECLARE @Role VARCHAR(125) 
DECLARE @SQL NVARCHAR(250)
IF EXISTS (SELECT Name
FROM sys.database_principals
WHERE Name = @PrincipalName)
BEGIN
    PRINT @PrincipalName + ' User Exists in ' + db_name() + ' on ' + @@SERVERNAME
END
ELSE
BEGIN
    PRINT 'Adding ' + @PrincipalName + ' to database '  + db_name() + ' on instance' + @@SERVERNAME
    SELECT @SQL = 'CREATE USER [' + @PrincipalName + '] FROM EXTERNAL PROVIDER'
    EXEC sp_executesql @SQL
END
SELECT @Role = 'loginmanager'
IF IS_ROLEMEMBER(@Role,@PrincipalName) = 1
BEGIN
PRINT @PrincipalName + ' User Exists in ' + @Role + ' in database ' + db_name() + ' on instance ' + @@SERVERNAME

END
ELSE
BEGIN
PRINT  'Adding ' + @PrincipalName + ' to ' + @Role + ' role in database ' + db_name() + ' on instance ' + @@SERVERNAME
SELECT @SQL = 'ALTER ROLE ' + @Role + ' ADD MEMBER [' + @PrincipalName + ']'
EXEC sp_executesql @SQL
END

