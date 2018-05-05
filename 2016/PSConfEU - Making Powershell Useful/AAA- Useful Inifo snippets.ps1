
## Total size of files in a folder

(gci PSFunctions:\  -recurse -force | Measure-Object -sum -property Length).Sum/1KB

## Count the number of files in a folder

(Get-ChildItem Presentations:\ -recurse | Where-Object {$_.Extension -eq ".xls"} ).Count
(Get-ChildItem Presentations:\ -recurse | Where-Object {$_.Extension -eq ".pptx"} ).Count

## SMO first start

$instancename = '.'
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server `
          -ArgumentList $instanceName;
## $server | Get-Member

## SMO default  files locations are here

$instancename = '.'
$server = New-Object "Microsoft.SqlServer.Management.Smo.Server" $instanceName;
write-host 'Default Backup Folder      ' $server.settings.BackupDirectory
write-host 'Default Data File Folder      ' $server.settings.DefaultFile
write-host 'Default Log File Folder      ' $server.settings.DefaultLog

##List databases


$instancename = '.'
$server = New-Object  "Microsoft.SqlServer.Management.Smo.Server" $instanceName;
foreach($Database in $Server.databases) {$Database.name}

$srv ='.'
$db = New-Object Microsoft.SqlServer.Management.Smo.Database ($srv, "DBADatabase")
$db.dataspaceusage

$server ='.'
$SMOserver = New-Object ('Microsoft.SqlServer.Management.Smo.Server') -argumentlist $Server

$SMOserver.Databases | select Name, Size, DataSpaceUsage, IndexSpaceUsage, SpaceAvailable | Format-Table



