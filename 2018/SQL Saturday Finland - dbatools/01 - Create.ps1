#region Create New PSDrive and prompt
if(-not (Get-PSDrive -Name Finland -ErrorAction SilentlyContinue)){
    New-PSDrive -Name Finland -Root 'C:\Git\Presentations\2018\SQL Saturday Finland - dbatools' -PSProvider FileSystem
}

function prompt {
    Write-Host ("Hymyile ja nauti >") -NoNewLine -ForegroundColor Magenta
    return " "
}

cd finland:

# remove sql file for export if exists

(Get-ChildItem *sql0-LinkedServer-Export*).ForEach{Remove-Item $Psitem -Force}

#endregion

#region Create a share
$Share = '\\jumpbox.TheBeard.Local\SQLBackups'
$ShareName = 'SQLBackups'
$ShareFolder = 'C:\SQLBackups'
$Full = 'THEBEARD\Domain Admins'
$Change = 'THEBEARD\Domain Users'
$Read = 'EveryOne'
if (-not (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue)) {
    if (-not (Test-Path $ShareFolder)) {
        New-Item $ShareFolder -ItemType Directory
    }

    $newSMBShareSplat = @{
        Name                  = $ShareName
        FullAccess            = $Full
        ChangeAccess          = $Change
        Path                  = $ShareFolder
        Description           = "Location for the SQL Backups"
        ReadAccess            = $Read
    }
    New-SMBShare @newSMBShareSplat -Verbose
}

## Create share on dockerhost
Enter-PSSession bearddockerhost
$NetworkShare = '\\bearddockerhost.TheBeard.Local\NetworkSQLBackups'
$ShareName = 'NetworkSQLBackups'
$ShareFolder = 'E:\NetworkSQLBackups'
$Full = 'EveryOne'
if (-not (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue)) {
    if (-not (Test-Path $ShareFolder)) {
        New-Item $ShareFolder -ItemType Directory
    }

    $newSMBShareSplat = @{
        Name                  = $ShareName
        FullAccess            = $Full
        Path                  = $ShareFolder
        Description           = "Location for the Network SQL Backups"
    }
    New-SMBShare @newSMBShareSplat -Verbose
}
Exit

Get-ChildItem $NetworkShare | Remove-Item -Recurse -Force
#endregion

#region copy backups
# Copy backups to the folder

$backupfiles = Get-ChildItem $HOME\Downloads\Adventure*bak

if(-not (Test-Path $ShareFolder\Keep)){
    New-Item $ShareFolder\Keep -ItemType Directory
}

$backupfiles.ForEach{Copy-Item $Psitem -Destination $ShareFolder\Keep}

#endregion

#region Create containers and volume

# docker volume create SQLBackups

# docker run -d -p 15789:1433 -v sqlbackups:C:\SQLBackups -e sa_password=Password0! -e ACCEPT_EULA=Y microsoft/mssql-server-windows-developer 
# docker run -d -p 15788:1433 -v sqlbackups:C:\SQLBackups -e sa_password=Password0! -e ACCEPT_EULA=Y dbafromthecold/sqlserver2016dev:sp1
# docker run -d -p 15787:1433 -v sqlbackups:C:\SQLBackups -e sa_password=Password0! -e ACCEPT_EULA=Y dbafromthecold/sqlserver2014dev:sp2 
# docker run -d -p 15786:1433 -v sqlbackups:C:\SQLBackups -e sa_password=Password0! -e ACCEPT_EULA=Y dbafromthecold/sqlserver2012dev:sp4 

#endregion

#region restore databases
$containers = 'bearddockerhost,15789', 'bearddockerhost,15788', 'bearddockerhost,15787', 'bearddockerhost,15786'
$filenames = (Get-ChildItem C:\SQLBackups\Keep).Name
$cred = Import-Clixml $HOME\Documents\sa.cred

$containers.ForEach{
    $Container = $Psitem
    $NameLevel = (Get-DbaSqlBuildReference -SqlInstance $Container -SqlCredential $cred).NameLevel
    $NameLevel
    switch ($NameLevel) {
        2017 { 
            Restore-DbaDatabase -SqlInstance $Container -SqlCredential $cred -Path C:\sqlbackups\ -useDestinationDefaultDirectories -WithReplace            
        }
        2016 {
            $Files = $Filenames.Where{$PSitem -notlike '*2017*'}.ForEach{'C:\sqlbackups\' + $Psitem}
            Restore-DbaDatabase -SqlInstance $Container -SqlCredential $cred -Path $Files -useDestinationDefaultDirectories -WithReplace            
        }
        2014 {
            $Files = $Filenames.Where{$PSitem -notlike '*2017*' -and $Psitem -notlike '*2016*'}.ForEach{'C:\sqlbackups\' + $Psitem}
            Restore-DbaDatabase -SqlInstance $Container -SqlCredential $cred -Path $Files -useDestinationDefaultDirectories -WithReplace            
        }
        2012 {
            $Files = $Filenames.Where{$PSitem -like '*2012*'}.ForEach{'C:\sqlbackups\' + $Psitem}
            Restore-DbaDatabase -SqlInstance $Container -SqlCredential $cred -Path $Files -useDestinationDefaultDirectories -WithReplace            
        }
        Default {}
    }
}

# restore databases onto sql0

Restore-DbaDatabase -SqlInstance sql0 -Path $share -useDestinationDefaultDirectories -WithReplace 

# create folder for backups and empty it if need be
If(-Not (Test-Path C:\SQLBackups\SQLBackupsForTesting -ErrorAction SilentlyContinue)){
    New-Item C:\SQLBackups\SQLBackupsForTesting -ItemType Directory
}
Get-ChildItem C:\SQLBackups\SQLBackupsForTesting | Remove-item -Force

# remove databases from sql1 
Get-DbaDatabase -SqlInstance sql1 -ExcludeAllSystemDb -ExcludeDatabase WideWorldImporters | Remove-DbaDatabase -Confirm:$False
#endregion

#region Create linked server
# add to sql0
$Containers.ForEach{ 
    $Query = "IF NOT EXISTS
    (SELECT * FROM sys.servers WHERE name = '" + $PSitem + "')
    BEGIN
    EXEC master.dbo.sp_addlinkedserver @server = N'" + $PSitem + "', @srvproduct=N'SQL Server'
    EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'" + $PSitem + "', @locallogin = NULL , @useself = N'False', @rmtuser = N'sa', @rmtpassword = N'Password0!'
    END"
    Invoke-DbaSqlQuery -SqlInstance sql0 -Database master -Query $query
}
#remove from sql1
$Containers.ForEach{ 
    $Query = "IF EXISTS
    (SELECT * FROM sys.servers WHERE name = '" + $PSitem + "')
    BEGIN
    EXEC master.sys.sp_dropserver '" + $PSitem + "','droplogins'   END"
    Invoke-DbaSqlQuery -SqlInstance sql1 -Database master -Query $query
}
#endregion

#region linux server

Get-DbaDatabase -SqlInstance $LinuxSQL -SqlCredential $cred -ExcludeAllSystemDb | Remove-DbaDatabase -Confirm:$false

Invoke-DbaSqlQuery -SqlInstance $LinuxSQL -SqlCredential $cred -Database master -Query "CREATE DATABASE [DBA-Admin]"

(0..20)| ForEach-Object{
Invoke-DbaSqlQuery -SqlInstance $LinuxSQL -SqlCredential $cred -Database master -Query "CREATE DATABASE [LinuxDb$Psitem]"
}
#endregion
















