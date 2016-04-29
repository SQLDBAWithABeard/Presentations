## If you dont have a SQL Server try starting here
## $Files = Get-ChildItem -Path C:\temp -Recurse
## Files | Get-Member and find some properties to investigate

$Server = ''  # ServerName Here
$dbName = ''  # Database Name Here
$srv = New-Object Microsoft.SQLSErver.Management.SMO.Server $Server
$srv | Get-Member -MemberType Property
$db = $srv.Databases[$dbName]
$db | Get-Member -MemberType Property
$db.Tables | Get-Member -MemberType Property
$Index = $db.Tables.Indexes
$Index | Get-Member -MemberType Property

# CTRL J - choose foreach and create the code below
# Note there are more performant ways to do this that you should learn later
# But this process will help get you started




foreach($Table in $db.Tables)
    {
    foreach ($Index in $Table.Indexes)
        {
        $Index|select Name,Parent,FileGroup

        }
    }

