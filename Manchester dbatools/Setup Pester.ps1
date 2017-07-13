## F5 this one Rob because then you find out you arent running as Administrator
 #Requires -RunAsAdministrator
cd presentations:\
# Import-Module GIT:\dbatools\dbatools.psd1 -Verbose
(Get-DbaTable -SqlInstance Rob-XPS\SQL2016 -Database DBA-Admin -Table ManchesterDemo).Drop() 
$script = @"
CREATE TABLE [dbo].[ManchesterDemo](
	[id] [int] NOT NULL,
	[Bolton] [nchar](10) NULL
) ON [PRIMARY]
"@
Invoke-Sqlcmd -ServerInstance Rob-xps\SQL2016 -Database DBA-Admin -Query $script 
   
Describe "SQL State" {
    $SQLServers = 'ROB-XPS\SQL2016','ROB-XPS\Bolton'
    foreach ($Server in $SQLServers) {
        Context "Checking SQL $Server" {
            if ($Server.Contains('\')) {
                $ServerName = $Server.Split('\')[0]
                $Instance = $Server.Split('\')[1]
            }
            else {
                $Servername = $Server
                $Instance = 'MSSQLSERVER'
            } 
            If ($Instance -eq 'MSSQLSERVER') {
                $SQLService = $Instance
                $AgentService = 'SQLSERVERAGENT'
            }
            else {
                $SQLService = "MSSQL$" + $Instance
                $AgentService = "SQLAgent$" + $Instance
            }
            $DBEngine = Get-service -ComputerName $Servername -Name $SQLService
            It "$Server  DBEngine should be running" {
                $DBEngine.Status | Should Be 'Running'
            }
            It "$Server DBEngine Should Not be Auto Start" {
                $DBEngine.StartType | Should be 'Manual'
            }
            $Agent = Get-service -ComputerName $Servername -Name $AgentService
            It "$Server Agent should be running" {
                $Agent.Status | Should Be 'Running'
            }
            It "$Server Agent Should Not be Auto Start" {
                $Agent.StartType | Should be 'Manual'
            }
        }
    }
    It "Should have SQL Browser running" {
        (Get-Service SQLBrowser).Status | Should Be 'Running'
    }
    It "Should have Linux SQL running"{
        $cred = Import-Clixml C:\MSSQL\sa.cred 
        {Connect-DbaSqlServer -SqlInstance Bolton -Credential $cred} | Should Not Throw
    }
}

Describe "Testing for Presentation" {
    Context "Rob-XPS" {
        It "Shoudl have Code Insiders Open" {
            (Get-Process 'Code - Insiders'  -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        }
        It "Should have PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Not Be 0
        }
        It "Should have One PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Be 1
        }

        It "Should have the correct PowerPoint Presentation Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).MainWindowTitle| Should Be 'Green is Good - Red is Bad - PowerPoint'
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
        It "Should be running as rob-xps\mrrob" {
            whoami | Should Be 'rob-xps\mrrob'
        }
        It "Hyper-V Should Be Running" {
            (Get-Service vmcompute).Status | Should Be 'Running'
        }
        It "Bolton Should Be Running" {
            (Get-VM Bolton -ErrorAction SilentlyContinue).State | Should Be 'Running'
        }
        It "Should have the path for saving the diagnostics reports"{
            Test-Path C:\Temp\Diagnostics | Should Be $true
        }
    }
}

Describe "Testing for Demo - SQL2016 Instance"{
    $SQL = 'Rob-XPS\SQL2016'
    It "Should have the correct Demo Logins"{
        (Get-DbaLogin -SqlInstance $SQL).Where{$_.Name -like '*ManchesterDemo*'}.Count | Should Be 15
    }
    It "Should have the correct credential" {
        (Get-DbaCredential -SqlInstance $sql).Where{$_.Name -like '*Manchester*'}.Count | Should Be 1
    }
    It "Should have an audit" {
        (Get-DbaServerAudit -SqlInstance $sql).Where{$_.Name -like '*Manchester*'}.Count | Should Be 1
    }
    It "Should have an audit specification" {
        (Get-DbaServerAuditSpecification -SqlInstance $sql).Where{$_.Name -like '*Manchester*'}.Count | Should Be 1
    }
    It "Should have a linked Server"{
        $SQL2016 = Connect-DbaSqlServer -SqlInstance 'Rob-XPS\SQL2016'
        $SQL2016.LinkedServers.Where{$_.Name -like '*Manchester*'}.Count | Should Be 1
    }
    It "Should have Agent Jobs"{
        (Get-DbaAgentJob -SqlInstance $SQL).Count | Should BeGreaterThan 14
    }
    It "Should have Agent Alerts"{
        (Get-DbaAgentAlert -SqlInstance $SQL).Count| Should BeGreaterThan 13
    }
    It "Should have Operators"{
        (Get-DbaAgentOperator -SqlInstance $SQL).Count | Should BeGreaterThan 1
    }
    It "Should have a proxy"{
        $SQL2016 = Connect-DbaSqlServer -SqlInstance 'Rob-XPS\SQL2016'
        $SQL2016.JobServer.ProxyAccounts.Count | Should BeGreaterThan 0
    }
}

Describe "Testing for Demo - Bolton Instance" {
    $SQL = 'ROB-XPS\Bolton'
    $BOLTON = Connect-DbaSqlServer -SqlInstance $SQL 
    It "Should have the correct Demo Logins" {
        $exclude = '##MS_PolicyEventProcessingLogin##', '##MS_PolicyTsqlExecutionLogin##', 'NT AUTHORITY\SYSTEM', 'BUILTIN\Administrators', 'NT AUTHORITY\NETWORK SERVICE', 'sa','NT Service\MSSQL$BOLTON','NT SERVICE\SQLAgent$BOLTON','NT SERVICE\SQLTELEMETRY$BOLTON','NT SERVICE\SQLWriter','NT SERVICE\Winmgmt','ROB-XPS\mrrob'
        (Get-DbaLogin -SqlInstance $SQL ).Where{$_.Name -notin $exclude}.Count | Should Be 0
    }
    It "Should have the correct number of credentials" {
        (Get-DbaCredential -SqlInstance $sql ).Count | Should Be 0
    }
    It "Should not have an audit" {
        (Get-DbaServerAudit -SqlInstance $SQL ).Count | Should Be 0
    }
    It "Should not have an audit specification" {
        (Get-DbaServerAuditSpecification -SqlInstance $SQL).Count | Should Be 0
    }
    It "Should Not have a linked Server" {
        $BOLTON.LinkedServers.Where{$_.Name -like '*Manchester*'}.Count | Should Be 0
    }
    It "Should have only one Agent Job" {
        (Get-DbaAgentJob -SqlInstance $SQL ).Count | Should Be 1
    }
    It "Should not have Agent Alerts" {
        (Get-DbaAgentAlert -SqlInstance $SQL ).Count| Should Be 0
    }
    It "Should not have Operators" {
        (Get-DbaAgentOperator -SqlInstance $SQL -SqlCredential $cred).Count | Should Be 0
    }
    It "Should not have a proxy" {
        $Bolton.JobServer.ProxyAccounts.Count | Should Be 0
    }
}

