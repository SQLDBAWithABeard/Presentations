## Total size of files in a folder

(gci FOLDERPATH -recurse -force | Measure-Object -sum -property Length).Sum/1GB

## Count the number of files in a folder

(Get-ChildItem FOLDERNAME -recurse | Where-Object {$_.Extension -eq ".xls"} ).Count


## SMO first start
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
$instancename = '.'
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server `
          -ArgumentList $instanceName;
$server | Get-Member

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
$db = New-Object Microsoft.SqlServer.Management.Smo.Database ($srv, "")
$db.dataspaceusage

$server ='.'
$SMOserver = New-Object ('Microsoft.SqlServer.Management.Smo.Server') -argumentlist $Server

$SMOserver.Databases | select Name, Size, DataSpaceUsage, IndexSpaceUsage, SpaceAvailable | Format-Table



