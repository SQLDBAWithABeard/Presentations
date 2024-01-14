# sqlcmd demo

# how to install go-sqlcmd

choco install sqlcmd -y

# As with all things, you can get help with sqlcmd by using the --help flag

sqlcmd --help

# you can still run the old version of sqlcmd

Push-Location Git:\dbatools\bin\sqlcmd

.\sqlcmd.exe -?++

Pop-Location

# the new version still has the original flags, including the help ;-)

sqlcmd -?
sqlcmd --help

# you can also get help for a specific command
# Lets look at the create mssql command

sqlcmd create mssql --help

# if you want to create a new sql container, you can use any of the following versions
sqlcmd create mssql get-tags

# lets create a new sql container
sqlcmd create mssql --accept-eula --cached

# It even tells you what you can do next

code C:\Users\mrrob\.sqlcmd\sqlconfig

sqlcmd config view
sqlcmd config view --raw
sqlcmd config --help


sqlcmd query ""

sqlcmd delete

[System.Environment]::SetEnvironmentVariable('SQLCMD_ACCEPT_EULA','YES', 'Machine')

sqlcmd create mssql --accept-eula --cached --user-database Dublin

sqlcmd query "SELECT Name From sys.databases"

sqlcmd query --help

sqlcmd query "SELECT DB_NAME() AS [Current Database]" --database Dublin

sqlcmd --input-file 'dataceili.sql' --database-name Dublin

sqlcmd query "SELECT Name FROM sys.tables" --database Dublin

sqlcmd query "SELECT  COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'table holding data with a bad name'" --database Dublin
sqlcmd --query "SELECT  COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'table holding data with a bad name'" --database-name Dublin --format="vert"

sqlcmd delete

sqlcmd create mssql --accept-eula --cached --using https://aka.ms/AdventureWorksLT.bak

sqlcmd open ads

sqlcmd delete