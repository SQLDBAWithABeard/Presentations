# sqlcmd demo

# how to install go-sqlcmd

# choco install sqlcmd -y
# winget install sqlcmd

sqlcmd create mssql --accept-eula --cached

sqlcmd open ads

sqlcmd --version

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

Invoke-DbaQuery -SqlInstance 'localhost,1433' -SqlCredential $cred -Query "SELECT Name From sys.databases"

# but we cna just use sqlcmd and create a database
sqlcmd query "CREATE DATABASE Metallica"

# We can also use sqlcmd to open a database in Azure Data Studio

sqlcmd open ads

# lets talk about passwords

sqlcmd create mssql --help

# lets create another container, this time with a user database

sqlcmd create mssql --accept-eula --cached --user-database killswitchengage

# notice we have a new context

# which databases do we have?

sqlcmd query "SELECT Name From sys.databases"

sqlcmd query --help

# run a query against the killswitchengage database

sqlcmd query "SELECT DB_NAME() AS [Current Database]" --database killswitchengage

# run a query file against the killswitchengage database

sqlcmd --input-file 'dataceili.sql' --database-name killswitchengage

# what do we have?

sqlcmd query "SELECT Name FROM sys.tables" --database killswitchengage

# the sort of things to make you go hmmmm

sqlcmd query "SELECT  COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'table holding data with a bad name'" --database killswitchengage
sqlcmd --query "SELECT  COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'table holding data with a bad name'" --database-name killswitchengage --format="vert"

# I can open an interactive session

sqlcmd

# and then list colour schemes
<#
:list color

:setvar SQLCMDCOLORSCHEME doom-one2

SELECT  COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'table holding data with a bad name'
GO
#>

# so that was the container with the killswitchengage database. What about the other one?

# we can switch contexts (like kubectl)

sqlcmd config use-context mssql

sqlcmd query "SELECT Name From sys.databases"

# we can delete the container (and the context)

ysqlcmd delete

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

sqlcmd create mssql --name dbachecks --hostname WilliamDurkin  --accept-eula --cached --context-name dbachecks1 --registry dbachecks --repo sqlinstance1 --tag v2.38.0  --verbosity 4

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

sqlcmd delete

# so this is a bit interesting but there is an issue opened. See sqlcmd is open-source and you can help to guide the direction of the project.
https://github.com/microsoft/go-sqlcmd/issues/372

sqlcmd config view

sqlcmd delete --force --yes

sqlcmd delete-context dbachecks

sqlcmd config add-endpoint --name dbachecks1 --address localhost

sqlcmd config delete-user --name sqladmin

# what about Azure?

<#
--authentication-method
Specifies the SQL authentication method to use to connect
to Azure SQL Database. One of:
ActiveDirectoryDefault,
ActiveDirectoryIntegrated,
ActiveDirectoryPassword,
ActiveDirectoryInteractive,
ActiveDirectoryManagedIdentity,
ActiveDirectoryServicePrincipal,
SqlPassword
#>

# Make sure that we are logged in to Azure
# This requires Azure CLI to be installed and logged in

az login
az account set --subscription '6d8f994c-9051-4cef-ba61-528bab27d213'

sqlcmd -S beardenergysrv.database.windows.net -d Strava --authentication-method ActiveDirectoryIntegrated --format="vert"

SELECT [name]
      ,[type]
      ,[distance]
      ,[moving_time]
      ,[total_elevation_gain]
      ,[start_date_local]
      ,[average_cadence]
      ,[average_watts]
      ,[average_heartrate]
  FROM [dbo].[activities]
WHERE id = 8287070797
GO

:setvar SQLCMDCOLORSCHEME doom-one2













## new things

cd C:\temp\sqlcmd-319

$env:SQLCMD_ACCEPT_EULA='YES'

./sqlcmd --help


# I want to restore a backup

./sqlcmd create mssql --cached --using https://aka.ms/AdventureWorksLT.bak

# query it
./sqlcmd query "SELECT DB_NAME()"

# remove it
./sqlcmd delete --force --yes

# Lets see the new things

# restore from a file into an existing container
./sqlcmd create mssql --cached

# restore the file into it
./sqlcmd use https://aka.ms/AdventureWorksLT.bak

# query it
./sqlcmd query "SELECT DB_NAME()"

# remove it
./sqlcmd delete --force --yes

# I dont have a file in an URL with a .bak extension

# restore from a file into an existing container
./sqlcmd create mssql --cached

# I want to restore some database backup into it
./sqlcmd use c:\temp\backup\somedatabase.bak

# query it
./sqlcmd query "SELECT DB_NAME()"

# remove it
./sqlcmd delete --force --yes


# I want to restore some database backup as that database name

# restore from a file into an existing container
./sqlcmd create mssql --cached

# restore a local file into it as a different name
./sqlcmd use c:\temp\backup\somedatabase.bak,thatdatabasename

# query it
./sqlcmd query "SELECT DB_NAME()"

# remove it
./sqlcmd delete --force --yes

# I am organised, can I do it all in one line please. Just restore when I create please

./sqlcmd create mssql --cached --use c:\temp\backup\somedatabase.bak

# query it
./sqlcmd query "SELECT DB_NAME()"

# remove it
./sqlcmd delete --force --yes

# I am organised, can I do it all in one line please.

./sqlcmd create mssql --cached --use c:\temp\backup\somedatabase.bak,yetanotherdatabasenamejusttoshowyouican

# query it
./sqlcmd query "SELECT DB_NAME()"

# remove it
./sqlcmd delete --force --yes

# I am organised, AND LAZY, can I do it all in one line please.

./sqlcmd create mssql --cached --use c:\temp\backup\somedatabase.bak,anevenlongerdatabasenametoseeifanyoneisreadingthissaybeard --open ads

# query it
./sqlcmd query "SELECT DB_NAME()"


# remove it
./sqlcmd delete --force --yes

# I dont have a .bak but I want to attach an mdf file please

./sqlcmd create mssql --cached --using C:\temp\backup\anotherdatabaseforwilliam.mdf,anotherdatabaseforwilliam

# query it
./sqlcmd query "SELECT DB_NAME()"
./sqlcmd query "SELECT name from sys.databases"

# remove it
./sqlcmd delete --force --yes

# We live in a modern world, my backup is in Azure Storage

./sqlcmd create mssql --cached --use 'https://beardsqlbaks1.blob.core.windows.net/backups/someonlinedeebeebackup.bak?sp=racwd&st=2023-09-12T15:31:05Z&se=2023-09-17T23:31:05Z&spr=https&sv=2022-11-02&sr=b&sig=FRda2aEhH6aBk2rNLmtQ4zcJbi8ykWHCWM4OaSGDlpQ%3D' --verbosity 5


# query it
./sqlcmd query "SELECT DB_NAME()"

# remove it
./sqlcmd delete --force --yes




GOOS=windows GOARCH=amd64 go build -o ../sqlcmd.exe -ldflags="-X main.version=1.7" ../cmd/modern

2019-latest

wget -O /var/opt/mssql/backup.bak 'https://beardsqlbaks1.blob.core.windows.net/backups/someonlinedeebeebackup.bak?sp=racw&st=2023-09-12T14:16:53Z&se=2023-10-03T22:16:53Z&sv=2022-11-02&sr=b&sig=hu1nLNRxs12YF1vbFL0K9%2FuWXEh5G4SaqCoYwc3PCDc%3D'