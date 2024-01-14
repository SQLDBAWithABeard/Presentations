cd C:\temp\sqlcmd-319

$env:SQLCMD_ACCEPT_EULA='YES'

# create a container
./sqlcmd create mssql --cached

# query it
./sqlcmd query "SELECT DB_NAME()"

# remove it
./sqlcmd delete --force --yes

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

# restore a local file into it
./sqlcmd use c:\temp\backup\somedatabase.bak

# query it
./sqlcmd query "SELECT DB_NAME()"

# remove it
./sqlcmd delete --force --yes


# I want to restore the database as a different name

# restore from a file into an existing container
./sqlcmd create mssql --cached

# restore a local file into it as a different name
./sqlcmd use c:\temp\backup\somedatabase.bak,anotherdatabase

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

./sqlcmd create mssql --cached --use c:\temp\backup\somedatabase.bak,yetanotherdatabase

# query it
./sqlcmd query "SELECT DB_NAME()"

# remove it
./sqlcmd delete --force --yes

# I am organised, AND LAZY, can I do it all in one line please.

./sqlcmd create mssql --cached --use c:\temp\backup\somedatabase.bak,yetanotherdatabase --open ads

# query it
./sqlcmd query "SELECT DB_NAME()"

# remove it
./sqlcmd delete --force --yes

# I dont have a .bak but I want to attach an mdf file please

./sqlcmd create mssql --cached --use C:\temp\backup\moreagaindatabase.mdf

# query it
./sqlcmd query "SELECT DB_NAME()"

# remove it
./sqlcmd delete --force --yes

# We live in a modern world, my backup is in Azure Storage

./sqlcmd create mssql --cached --use "https://beardsqlbaks1.blob.core.windows.net/backups/someonlinedeebeebackup.bak?sp=racwdyt&st=2023-10-10T09:04:34Z&se=2023-12-31T18:04:34Z&spr=https&sv=2022-11-02&sr=b&sig=c0ZdYuB1lJmdRYhjQit147BPaNBgq5rmfun2roBUiuw%3D"

# query it
./sqlcmd query "SELECT DB_NAME()"

# remove it
./sqlcmd delete --force --yes




