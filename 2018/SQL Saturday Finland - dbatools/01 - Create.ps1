
# Create a share
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

# Copy backups to the folder

$backupfiles = Get-ChildItem $HOME\Downloads\Adventure*bak

if(-not (Test-Path $ShareFolder\Keep)){
    New-Item $ShareFolder\Keep -ItemType Directory
}

$backupfiles.ForEach{Copy-Item $Psitem -Destination $ShareFolder\Keep}

# Create containers and volume

# docker volume create SQLBackups

# docker run -d -p 15789:1433 -v sqlbackups:C:\SQLBackups -e sa_password=Password0! -e ACCEPT_EULA=Y microsoft/mssql-server-windows-developer 
# docker run -d -p 15788:1433 -v sqlbackups:C:\SQLBackups -e sa_password=Password0! -e ACCEPT_EULA=Y dbafromthecold/sqlserver2016dev:sp1
# docker run -d -p 15787:1433 -v sqlbackups:C:\SQLBackups -e sa_password=Password0! -e ACCEPT_EULA=Y dbafromthecold/sqlserver2014dev:sp2 
# docker run -d -p 15786:1433 -v sqlbackups:C:\SQLBackups -e sa_password=Password0! -e ACCEPT_EULA=Y dbafromthecold/sqlserver2012dev:sp4 


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
