Remove-Module PSReadline
Set-Location 'GIT:\Presentations\2019\dbachecks'
Write-PSFMessage "Getting the variables" -Level Output 

$EndDate = Get-Date -Year 2019 -Month 9 -Day 20 -Hour 16 -Minute 30 -Second 0
# [datetime]$EndDate = '2019-04-17 20:33'
$location = 'Bangalore'
$ShowCountDown = $true
$CountDownMessage = "dbachecks is awesome in $location "

. .\vars.ps1
Write-PSFMessage "Working on ROB-XPS" -Level Output 

# Import-Module dbatools -RequiredVersion 0.9.534
Import-Module dbachecks

$PSDefaultParameterValues += @{
    '*db*:SqlCredential' = $cred
    '*db*:DestinationSqlCredential' = $cred
    '*db*:SourceSqlCredential' = $cred
}

if ($ENV:COMPUTERNAME -eq 'JumpBox') {

    #region Create New PSDrive and prompt
    if (-not (Get-PSDrive -Name $location -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name $location -Root 'C:\Git\Presentations\2018\SQL Saturday Holland\' -PSProvider FileSystem | Out-Null
        Write-Verbose -Message "Created PSDrive"
    }

    Write-Verbose -Message "Created prompt"

    $promptloc = $location + ':'
    Set-Location $promptloc


    #region Create containers and volume

    # docker volume create SQLBackups

    $session = New-PSSession bearddockerhost
    Write-Verbose -Message "Created session on dockerhost"
    $Scriptblock = {docker run -d -p 15789:1433 --name 2017 -v sqlbackups:C:\SQLBackups -e sa_password=Password0! -e ACCEPT_EULA=Y microsoft/mssql-server-windows-developer 
        docker run -d -p 15788:1433 --name 2016 -v sqlbackups:C:\SQLBackups -e sa_password=Password0! -e ACCEPT_EULA=Y dbafromthecold/sqlserver2016dev:sp1 
        docker run -d -p 15787:1433 --name 2014 -v sqlbackups:C:\SQLBackups -e sa_password=Password0! -e ACCEPT_EULA=Y dbafromthecold/sqlserver2014dev:sp2 
        docker run -d -p 15786:1433 --name 2012 -v sqlbackups:C:\SQLBackups -e sa_password=Password0! -e ACCEPT_EULA=Y dbafromthecold/sqlserver2012dev:sp4}

    $Dockerstart = {
        docker start 2017
        docker start 2014
        docker start 2016
        docker start 2012
    }

    # Invoke-Command -Session $session -ScriptBlock $scriptBlock 
    # Write-Verbose -Message "Created containers"
    Invoke-Command -Session $session -ScriptBlock $Dockerstart
    Write-Verbose -Message "Started containers"
    Remove-PSSession $session

    #endregion

    #region restore databases

    $containers.ForEach{
        $Container = $Psitem
        $NameLevel = (Get-DbaSqlBuildReference -SqlInstance $Container -SqlCredential $cred).NameLevel
        Write-Verbose -Message "$NameLevel"
        switch ($NameLevel) {
            2017 { 
                Restore-DbaDatabase -SqlInstance $Container -SqlCredential $cred -Path C:\sqlbackups\ -useDestinationDefaultDirectories -WithReplace   |Out-Null         
                Write-Verbose -Message "Restored Databases on 2017"
            }
            2016 {
                $Files = $Filenames.Where{$PSitem -notlike '*2017*'}.ForEach{'C:\sqlbackups\' + $Psitem}
                Restore-DbaDatabase -SqlInstance $Container -SqlCredential $cred -Path $Files -useDestinationDefaultDirectories -WithReplace            
                Write-Verbose -Message "Restored Databases on 2016"
            }
            2014 {
                $Files = $Filenames.Where{$PSitem -notlike '*2017*' -and $Psitem -notlike '*2016*'}.ForEach{'C:\sqlbackups\' + $Psitem}
                Restore-DbaDatabase -SqlInstance $Container -SqlCredential $cred -Path $Files -useDestinationDefaultDirectories -WithReplace            
                Write-Verbose -Message "Restored Databases on 2014"
            }
            2012 {
                $Files = $Filenames.Where{$PSitem -like '*2012*'}.ForEach{'C:\sqlbackups\' + $Psitem}
                Restore-DbaDatabase -SqlInstance $Container -SqlCredential $cred -Path $Files -useDestinationDefaultDirectories -WithReplace            
                Write-Verbose -Message "Restored Databases on 2012"
            }
            Default {}
        }
    }

    # restore databases onto sql0

    Restore-DbaDatabase -SqlInstance $sql0 -Path $share -useDestinationDefaultDirectories -WithReplace 
    Write-Verbose -Message "Restored Databases on sql0"

    $query = "ALTER DATABASE [AdventureWorks2014] SET QUERY_STORE = ON
ALTER DATABASE [AdventureWorks2014] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, INTERVAL_LENGTH_MINUTES = 15)"

    (Get-DbaDatabase -SqlInstance $sql0 -Database master).Query($Query)

    $db = Get-DbaDatabase -SqlInstance $sql0 -Database AdventureWorks2014
    $db.Query("CREATE PROCEDURE dbo.SendEmailToMe
-- Add the parameters for the stored procedure here
@stolen nvarchar(MAX),
@Email nvarchar(40)
AS
BEGIN
Select @@ServerName
END
")
    $db.Query("
-- =============================================
-- Author:		Evil Thief
-- Create date: <A Long Long Time Ago
-- Description:	Once upon a time there were four little Rabbits, and their names were — Flopsy,Mopsy,Cotton-tail,and Peter.
-- They lived with their Mother in a sand-bank, underneath the root of a very big fir-tree.
-- =============================================
CREATE PROCEDURE dbo.Steal_All_The_Emails
	
AS
BEGIN
	DECLARE @StoleItAll nvarchar(MAX)= 'All'

	EXEC dbo.SendEmailToMe @stolen = @StoleItAll, @Email = 'IownAllOfYourThings@BadHacker.io'

END
")
    Write-Verbose -Message "Created stored procedures"

    # create folder for backups and empty it if need be
    If (-Not (Test-Path C:\SQLBackups\SQLBackupsForTesting -ErrorAction SilentlyContinue)) {
        New-Item C:\SQLBackups\SQLBackupsForTesting -ItemType Directory
        Write-Verbose -Message "Created Backup directory"
    }
    Get-ChildItem C:\SQLBackups\SQLBackupsForTesting | Remove-item -Force
    Write-Verbose -Message "Emptied backup directory"
    # remove databases from sql1 
    Get-DbaDatabase -SqlInstance $sql1 -ExcludeAllSystemDb -ExcludeDatabase WideWorldImporters | Remove-DbaDatabase -Confirm:$False
    Write-Verbose -Message "Removed databases from $SQL1"

    $db.Query("CREATE NONCLUSTERED INDEX [IX_Employee_OrganizationLevel_OrganizationNode1] ON [HumanResources].[Employee]
(
	[OrganizationLevel] ASC,
	[OrganizationNode] ASC,
	[loginid]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

ALTER INDEX [IX_Employee_OrganizationLevel_OrganizationNode1] ON [HumanResources].[Employee] DISABLE
")
    #endregion

    #region Create linked server
    # add to sql0
    $Containers.ForEach{ 
        $Query = "IF NOT EXISTS
    (SELECT * FROM sys.servers WHERE name = '" + $PSitem + "')
    BEGIN
    EXEC master.dbo.sp_addlinkedserver @server = N'" + $PSitem + "', @srvproduct=N'SQL Server'
    EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'" + $PSitem + "', @locallogin = NULL , @useself = N'False', @rmtuser = N'sqladmin', @rmtpassword = N'dbatools.IO'
    END"
        Invoke-DbaSqlQuery -SqlInstance $sql0 -Database master -Query $query
        Write-Verbose -Message "Added linked Servers to $SQL0"
    }
    #remove from sql1
    $Containers.ForEach{ 
        $Query = "IF EXISTS
    (SELECT * FROM sys.servers WHERE name = '" + $PSitem + "')
    BEGIN
    EXEC master.sys.sp_dropserver '" + $PSitem + "','droplogins'   END"
        Invoke-DbaSqlQuery -SqlInstance $sql1 -Database master -Query $query
        Write-Verbose -Message "Removed linked servers from $SQL1"
    }

    Get-DbaDatabase -SqlInstance $sql0 -Database AdventureWorks2014_CLONE |Remove-DbaDatabase -Confirm:$False
    #endregion

    #region linux server

    Get-DbaDatabase -SqlInstance $LinuxSQL -SqlCredential $cred -ExcludeAllSystemDb | Remove-DbaDatabase -Confirm:$false
    Write-Verbose -Message "removed databases from Linux instance"

    Invoke-DbaSqlQuery -SqlInstance $LinuxSQL -SqlCredential $cred -Database master -Query "CREATE DATABASE [DBA-Admin]"
    Write-Verbose -Message "Created DBA-Admin database"

    (0..20)| ForEach-Object {
        Invoke-DbaSqlQuery -SqlInstance $LinuxSQL -SqlCredential $cred -Database master -Query "CREATE DATABASE [LinuxDb$Psitem]"
    }
    Write-Verbose -Message "Created 20 dumb databases"
    Get-DbaAgentJob -SqlInstance $LinuxSQL -SqlCredential $cred |ForEach-Object {
        Remove-DbaAgentJob -SqlInstance $LinuxSQL -SqlCredential $cred -Job $PSItem -Confirm:$false
        Write-Verbose -Message "Removed all the agent jobs from linux instance"
    }
    #endregion

    #region SQL login 

    if (Get-DbaLogin -SqlInstance $SQL1 -Login TheBeard) {
        Get-DbaLogin -SqlInstance $SQL1 -Login TheBeard | Remove-DbaLogin -Confirm:$false  
        Write-Verbose -Message "removed theBeard from $SQL1"  
    }

    #endregion

    #region Extended Events

    $Sessions = (Get-DbaXEventSession -SqlInstance $sql0).Where{$_.Name -notin ('AlwaysOn_Health', 'system_health', 'telemetry_xevents')}
    Remove-DbaXESession -SqlInstance $sql0 -Session $Sessions.Name

    Get-DbaXESession -SqlInstance $SQL0 -Session AlwaysOn_health | Stop-DbaXESession
    Get-DbaXESession -SqlInstance $SQL0 -Session AlwaysOn_health | Start-DbaXESession

    Get-ChildItem '\\sql0\c$\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Log\*.xel' | Remove-Item -Force -ErrorAction SilentlyContinue

    #endregion




    $verbosePreference = 'SilentlyContinue'
}else{

    Set-Location 'GIT:\Presentations\2019\dbachecks\docker'
    Write-PSFMessage "Docker-Compose Up" -Level Output 
    docker-compose up -d
    Write-PSFMessage "Waiting for SQL in Containers to come up" -Level Output 
    $connect = Test-DbaConnection -SqlInstance $sql1  -WarningAction SilentlyContinue
    while ($connect.ConnectSuccess -ne $true) {
        Write-PSFMessage "Waiting for the SQL Connection test to pass" -Level Output 
        Start-Sleep -Seconds 10
        $connect = Test-DbaConnection -SqlInstance $sql1 -WarningAction SilentlyContinue
    }
    Write-PSFMessage "Containers are up" -Level Output 
    Write-PSFMessage "Restoring Database" -Level Output 
    $restoreDbaDatabaseSplat = @{
        SqlInstance                      = $sql0
        UseDestinationDefaultDirectories = $true
        Path                             = '/var/opt/mssql/backups/AdventureWorks2016_EXT.bak'
    }
    Restore-DbaDatabase @restoreDbaDatabaseSplat |OUt-Null
    Write-PSFMessage "Database restored" -Level Output 
    Write-PSFMessage "Linked Servers" -Level Output 
    $Containers.ForEach{ 
        $Query = "    
        EXEC master.sys.sp_dropserver 'SQL2014','droplogins';
        EXEC master.sys.sp_dropserver 'SQL2016','droplogins' "
        Invoke-DbaQuery -SqlInstance $psitem -Database master -Query $query
    }
    Write-PSFMessage "Dropped linked Servers" -Level Output 
$containers.ForEach{
    $container = $PSItem
    $InternalNames = 'dbatoolssql1','dbatoolssql2','dbatoolssql3','dbatoolssql4'
    $InternalNames.ForEach{ 
        $Query = "IF NOT EXISTS
    (SELECT * FROM sys.servers WHERE name = '" + $PSitem + "')
    BEGIN
    EXEC master.dbo.sp_addlinkedserver @server = N'" + $PSitem + "', @srvproduct=N'SQL Server'
    EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'" + $PSitem + "', @locallogin = NULL , @useself = N'False', @rmtuser = N'sqladmin', @rmtpassword = N'dbatools.IO'
    END"
        Invoke-DbaQuery -SqlInstance $container -Database master -Query $query
    }
}
Write-PSFMessage -Message "Added linked Servers to $containers" -Level Output

$query = @"
EXEC msdb.dbo.sp_delete_operator @name=N'The DBA Team';
EXEC msdb.dbo.sp_add_operator @name=N'The DBA Team', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'TheDBATeam@TheBeard.Local', 
        @category_name=N'[Uncategorized]';


"@
$Containers.ForEach{ 
    Invoke-DbaQuery -SqlInstance $psitem -Database master -Query $query
}

$query = "CREATE DATABASE ValidationResults"
Invoke-DbaQuery -SqlInstance $sql0 -Database master -Query $query

$Query = "CREATE SCHEMA dbachecks"
Invoke-DbaQuery -SqlInstance $sql0 -Database ValidationResults -Query $query
}

Reset-DbcConfig
Import-Module PSReadline