echo "running configure"
# load up environment variables
export $(xargs < /tmp/sapassword.env)
export $(xargs < /tmp/sqlcmd.env)
export PATH=$PATH:/opt/mssql-tools/bin

# set the configs
cp /tmp/mssql.conf /var/opt/mssql/mssql.conf

# start sqlk and give it a little time
/opt/mssql/bin/sqlservr & sleep 20 

# cat /var/opt/mssql/log/errorlog

echo  "loop until sql server is up and ready"
 for i in {1..50};
 do
     sqlcmd -S localhost -d master -Q "SELECT @@VERSION"
     if [ $? -ne 0 ];then
         echo "Waiting on Instance"
         cat /var/opt/mssql/log/errorlog
         sleep 2
     fi
 done

 # create sqladmin with dbatools.IO password and disable sa
sqlcmd -S localhost -d master -i /tmp/create-admin.sql

# change the default login to sqladmin instead of sa
export SQLCMDUSER=sqladmin

# restore database
 sqlcmd -S localhost -d master -i /tmp/restore-db.sql