# sqlcmd demo

# how to install go-sqlcmd

# choco install sqlcmd -y

# As with all things, you can get help with sqlcmd by using the --help flag

sqlcmd --help

# you can still run the old version of sqlcmd

Push-Location 'C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\130\Tools\Binn\'

.\sqlcmd.exe -?

Pop-Location

# the new version still has the original flags, including the help ;-)

sqlcmd -?
sqlcmd --help

# if you want to create a new sql container, you can use any of the following versions

sqlcmd create mssql get-tags

# lets create a new sql container
# I am using cached to save redownloading the image

sqlcmd create mssql --accept-eula --cached

# It even tells you what you can do next

# So lets take a look at the context file (think kubectl contexts)

code C:\Users\mrrob\.sqlcmd\sqlconfig

# there is a commang for that

sqlcmd config view

# Want to see the passwords ?
sqlcmd config view --raw

# Want to get the connection strings?
sqlcmd config connection-strings

# then you can create a cred object
$connectionstrings = sqlcmd config connection-strings

$passwordstring = (($connectionstrings -split "SQLCMDPASSWORD=")[-1] -split '"')[0]
[pscredential]$cred = New-Object System.Management.Automation.PSCredential ('mrrob',( $passwordstring|ConvertTo-SecureString -AsPlainText -Force))

# and then use it to connect to the database old skool :-)

sqlcmd -U mrrob -P $passwordstring -Q "SELECT Name From sys.databases"

# remember I said close? -P will return
sqlcmd --query "SELECT Name From sys.databases"

# Of course, I am going to show it in dbatools!!

Invoke-DbaQuery -SqlInstance localhost -SqlCredential $cred -Query "SELECT Name From sys.databases"

# Just so I can quickly talk about dbatools v2 and the trust cert
Set-DbatoolsConfig -Name sql.connection.trustcert -Value $true

Invoke-DbaQuery -SqlInstance localhost -SqlCredential $cred -Query "SELECT Name From sys.databases"

# but we cna just use sqlcmd and create a database
sqlcmd query "CREATE DATABASE DbJunk"

# lets talk about passwords

sqlcmd create mssql --help

# lets create another container, this time with a user database

sqlcmd create mssql --accept-eula --cached --user-database Dublin

# notice we have a new context

# which databases do we have?

sqlcmd query "SELECT Name From sys.databases"

sqlcmd query --help

# run a query against the Dublin database

sqlcmd query "SELECT DB_NAME() AS [Current Database]" --database Dublin

# run a query file against the Dublin database

sqlcmd --input-file 'dataceili.sql' --database-name Dublin

# what do we have?

sqlcmd query "SELECT Name FROM sys.tables" --database Dublin

# the sort of things to make you go hmmmm

sqlcmd query "SELECT  COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'table holding data with a bad name'" --database Dublin
sqlcmd --query "SELECT  COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'table holding data with a bad name'" --database-name Dublin --format="vert"

# I can open an interactive session

sqlcmd

# and then list colour schemes
<#
:list color

:setvar SQLCMDCOLORSCHEME doom-one2

SELECT  COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'table holding data with a bad name'
GO
#>

# so that was the container with the Dublin database. What about the other one?

# we can switch contexts (like kubectl)

sqlcmd config use-context mssql

sqlcmd query "SELECT Name From sys.databases"

# we can delete the container (and the context)

sqlcmd delete

# ok we need to force !!

# What about if we wanted to create a container with a user database from  a user database backup?

sqlcmd create mssql --accept-eula --cached --using https://aka.ms/AdventureWorksLT.bak

# thats neat

sqlcmd query "SELECT Name From sys.databases"

# We can also use sqlcmd to open a database in Azure Data Studio

sqlcmd open ads

# clean up

sqlcmd delete

# what about if we wanted to create a container from our own image ?
# and define the context name

sqlcmd create mssql --name dbachecks --hostname William  --accept-eula --cached --context-name dbachecks1 --registry dbachecks --repo sqlinstance1 --tag v2.36.0  --verbosity 4

# now we have a custom user in this container so the context wont work

sqlcmd config view

# so we can create a new user in the config file. We have to set the password as an environment variable

$env:SQLCMD_PASSWORD='dbatools.IO'
sqlcmd config add-user --name sqladmin --username sqladmin --password-encryption dpapi

sqlcmd config view

# and then a new context with the new user

sqlcmd config add-context --help

sqlcmd config add-context --name dbachecks-sqladmin --endpoint dbachecks1 --user sqladmin

# and now we will be able to log into the container and run a query

sqlcmd config use-context dbachecks-sqladmin
sqlcmd query "SELECT Name From sys.databases"

# and even open it in Azure Data Studio

sqlcmd open ads

# clean up

sqlcmd delete --force

sqlcmd config view

sqlcmd delete

sqlcmd delete-context dbachecks

sqlcmd config add-endpoint --name dbachecks1 --address localhost

sqlcmd config delete-user --name sqladmin