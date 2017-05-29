
<## NEED TO ADD NEW / CHANGED SERVERS RMS  #>
<# Set up and pre sessio test to make sure all is ok #>

<#
## Needs Both SQL Instances

cd presentations:\
try
{
    Start-Process powershell.exe -ArgumentList '-noprofile -command Get-Service MS*DAVE*,SQLAgent*DAVE | Start-Service' -Verb runas
}
catch
{
    Write-Warning "FAILED to start DAVE"
}
try
{
    Start-Process powershell.exe -ArgumentList '-noprofile -command Get-Service SQLSERVERAGENT,MSSQLSERVER|Start-Service' -Verb runas
}
catch
{
    Write-Warning "FAILED to start SQL"
}

try{
    Start-Process powershell.exe -ArgumentList '-noprofile -commandGet-Process Freedome* | Stop-Process -Force' -Verb Runas
}
catch{
    Write-Warning "Failed to stop freedome"
}

import-module sqlserver
import-module dbatools


## Max Mem
Set-DbaMaxMemory -SqlServer SQL2012Ser08AG1 ,SQL2012Ser08AG2, SQL2012Ser08AG3 -MaxMb 2147483647

Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Database
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -Incremental 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -Incremental 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -Incremental 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -Incremental 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -Incremental 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 
Backup-SqlDatabase -ServerInstance SQL2016N1 -Database VideoDemodbareports -BackupAction Log 

## Fill the column
$Query = @"
INSERT INTO [HumanResources].[Shift]
([Name],[StartTime],[EndTime],[ModifiedDate])
VALUES
( 'Made Up SHift ' + CAST(NEWID() AS nvarchar(MAX)),DATEADD(hour,-4, GetDate()),'07:00:00.0000000',GetDate())
"@
$x = 252
While($x -gt 0) {
Invoke-SQLCmd2 -ServerInstance ROB-XPS -Database AdventureWorks2014 -Query $Query
$x--
}

## Orphaned File

$X = 10
While($X -ne 0) {
$DBName = 'Orphan_' + $x
Create-Database -Server SQL2016N2 -DBName $DBName 
$x--
}
Start-Sleep -seconds 5
$srv = Connect-DbaSqlServer -SqlServer SQL2016N2
$srv.Databases.Where{$_.Name -like 'Orphan*'}.ForEach{$srv.DetachDatabase($_.Name,$false,$false)}


## do backup to get the Z drive

(Get-SqlAgentJob -ServerInstance sql2016n1 |Where-Object Name -like '*user*full*big*').Start()

#>

Describe "Testing NUC" {
    Context "VM State" {       
        $NUCServers = 'BeardDC1','BeardDC2','LinuxvNextCTP14','SQL2005Ser2003','SQL2012Ser08AG3','SQL2012Ser08AG1','SQL2012Ser08AG2','SQL2014Ser12R2','SQL2016N1','SQL2016N2','SQL2016N3','SQLVnextN1','SQL2008Ser12R2'
        $NUCVMs = Get-VM -ComputerName beardnuc | Where-Object {$_.Name -in $NUCServers}
            foreach($VM in $NUCVms)
                {
                $VMName = $VM.Name
                  It "$VMName Should be Running"{
                    $VM.State | Should Be 'Running'
                  }
			    }
    
Context "THEBEARD_Domain" {
            $NUCServers = 'BeardDC1','BeardDC2','LinuxvNextCTP14','SQL2005Ser2003','SQL2012Ser08AG3','SQL2012Ser08AG1','SQL2012Ser08AG2','SQL2014Ser12R2','SQL2016N1','SQL2016N2','SQL2016N3','SQLVnextN1','SQL2008Ser12R2'
            foreach($VM in $NUCServers)
                {
                                 It "$VM Should respond to ping" {
				(Test-Connection -ComputerName $VM -Count 1 -Quiet -ErrorAction SilentlyContinue) | Should be $True
				}
                }
    }
}
    Context "SQL State" {
        $SQLServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL*'  -and $_.State -eq 'Running'}).Name
        foreach($Server in $SQLServers)
        {
          $DBEngine = Get-service -ComputerName $Server -Name MSSQLSERVER
           It "$Server  DBEngine should be running" {
                $DBEngine.Status | Should Be 'Running'
            }
           It "$Server DBEngine Should be Auto Start" {
            $DBEngine.StartType | Should be 'Automatic'
           }
              $Agent= Get-service -ComputerName $Server -Name SQLSERVERAGENT
              It "$Server Agent should be running" {
                  $Agent.Status | Should Be 'Running'
           }
           It "$Server Agent Should be Auto Start" {
            $Agent.StartType | Should be 'Automatic'
           }
        }
        It "Linux SQL Server should be accepting connections" {
            $cred = Import-Clixml C:\temp\sa.xml
            {Connect-DbaSqlServer -SqlServer LinuxvnextCTP14 -Credential $cred -ConnectTimeout 60} | Should Not Throw
        }
    
    }
}

Describe "Testing XPS" {
  Context "XPS" {
        It "DBEngine is running" {
            (Get-Service mssqlserver).Status | Should Be Running
        }
        It "SQL Server Agent is running" {
            (Get-Service sqlserveragent).Status | Should Be Running
        }
        It "DAVE DBEngine is running" {
            (Get-Service mssql*Dave).Status | Should Be Running
        }
        It "DAVE Agent is running" {
            (Get-Service sqlagent*dave).Status | Should Be Running
        }
    }
      

} #end describe
Describe "Testing for Presentation" {
    Context "Rob-XPS" {
        <# It "Should have One PowerShell ISE Process" {
            (Get-Process powershell_ise -ErrorAction SilentlyContinue).Count | Should Be 1
        }#>
        It "Shoudl have Code Insiders Open" {
             (Get-Process 'Code - Insiders'  -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        }
        It "Should have PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Not BeNullOrEmpty 
        }
       It "Should have One PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Be 1
        }

        It "Should have the correct PowerPoint Presentation Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).MainWindowTitle| Should Be 'dbatools - SQL Server and PowerShell together - PowerPoint'
        }
        It "Mail Should be closed" {
            (Get-Process HxMail -ErrorAction SilentlyContinue).COunt | Should Be 0
        }
        It "Tweetium should be closed" {
            (Get-Process WWAHost -ErrorAction SilentlyContinue).Count | Should Be 0
        }
        It "Slack should be closed" {
            (Get-Process slack* -ErrorAction SilentlyContinue).Count | Should BE 0
        }
        It "Prompt should be Presentations" {
            (Get-Location).Path | Should Be 'Presentations:\'
        }
        It "Should be running as THEBEARD\Rob" {
            whoami | Should Be 'thebeard\rob'
        }
    }
}

Describe "Testing for Demo"{
    It "Should have DNS Servers for correct interface" {
        (Get-DnsClientServerAddress -InterfaceAlias 'Ethernet 3').Serveraddresses | Should Be @('10.0.0.1','10.0.0.2')
    }
    It "Should have correct gateway for alias"{
        (Get-NetIPConfiguration -InterfaceAlias 'Ethernet 3').Ipv4DefaultGateway.NextHop | Should Be '10.0.0.1'
    }
    It "Max Memory on SQl2012SerAG1 2 and 3 should be 2147483647" {
        (Connect-DbaSqlServer SQL2012Ser08AG1).Configuration.MaxServerMemory.RunValue | Should Be 2147483647
        (Connect-DbaSqlServer SQL2012Ser08AG2).Configuration.MaxServerMemory.RunValue | Should Be 2147483647
        (Connect-DbaSqlServer SQL2012Ser08AG3).Configuration.MaxServerMemory.RunValue | Should Be 2147483647
    }
    It "ShiftID LastValue Should be 255" {
        $a = Test-DbaIdentityUsage -SqlInstance ROB-XPS -Databases AdventureWorks2014 -NoSystemDb
        $a.Where{$_.Column -eq 'ShiftID'}.LastValue | should Be 255
    }
    It "Uses TheBeard\Rob"{
        $ENV:USERDNSDOMAIN | Should be 'THEBEARD.LOCAL'
        $Env:USERNAME | Should Be 'Rob'
    }
    It "has Orphaned Files ready"{
        (Find-DbaOrphanedFile -SqlServer SQL2016N2).Count | Should Be 30
    }
   
}



# Clean up
<#

$Query = @"
DELETE
  FROM [AdventureWorks2014].[HumanResources].[Shift]
  WHERE ShiftID > 3

  DBCC CHECKIDENT('HumanResources.Shift', RESEED, 3)
"@
Invoke-SQLCmd2 -ServerInstance ROB-XPS -Database AdventureWorks2014 -Query $Query

#>