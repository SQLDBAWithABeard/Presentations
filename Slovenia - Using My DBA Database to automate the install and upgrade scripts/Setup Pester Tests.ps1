
Describe "Testing pre AutoInstall" {
BeforeAll {
# To Load SQL Server Management Objects into PowerShell
   [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')  | out-null
  [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMOExtended')  | out-null
}
    Context "VM State" {       
        $NUCServers = 'SQL2005Ser2003','SQL2008Ser2008','SQL2014Ser12r2','SQL2016N1','SQL2016N2'
        if ((Test-Connection beardnuc -Count 1 -Quiet -ErrorAction SilentlyContinue) -eq $false) {
            It "beardnuc is not available" {
                $true | Should Be $true
            }
        }
        else
        {
        $NUCVMs = Get-VM -ComputerName beardnuc | Where-Object {$_.Name -in $NUCServers}
            foreach($VM in $NUCVms)
                {
                $VMName = $VM.Name
                  It "$VMName Should be Running"{
                    $VM.State | Should Be 'Running'
                  }
                }
        }
    } # end context vms
    Context "SQL State" {
        $SQLServers = 'SQL2005Ser2003','SQL2008Ser2008','SQL2014Ser12r2','SQL2016N1','SQL2016N2'
        foreach($Server in $SQLServers)
        {
         if ((Test-Connection $Server -Count 1 -Quiet -ErrorAction SilentlyContinue) -eq $false) {
            It "$Server is not available" {
                $true | Should Be $true
            }
        }
        else
        {
          $DBEngine = Get-service -ComputerName $Server -Name MSSQLSERVER
           It "DBEngine should be running" {
                $DBEngine.Status | Should Be 'Running'
            }
           It "DBEngine Should be Auto Start" {
            $DBEngine.StartType | Should be 'Automatic'
           }
          $Agent= Get-service -ComputerName $Server -Name SQLSERVERAGENT
           It "Agent should be running" {
                $Agent.Status | Should Be 'Running'
            }
           It "Agent Should be Auto Start" {
            $Agent.StartType | Should be 'Automatic'
           }
        $srv = New-Object Microsoft.SQLServer.Management.SMO.Server $Server
        if($Srv.Version -eq '')
        {
            It "$Server not contactable" {
            $true | Should Be $true
            }
        }
        else
        {
        It "$Server should not have sp_whoisActive" {
        ($Srv.Databases['master'].StoredProcedures.Name.Contains('sp_WhoIsActive'))| Should Be $false
        }
        if($srv.versionmajor -ge '11')
            {
            if(Test-Path SQLSERVER:\XEvent\$Server)
            {
            $XEStore = get-childitem -path SQLSERVER:\XEvent\$Server -ErrorAction SilentlyContinue  | where {$_.DisplayName -ieq 'default'}
            It "$Server should not have Basic Trace Extended Event Sesssion" {
            $XEStore.Sessions.Name.Contains('Basic_Trace') | Should Be $false
            }
            }
            }
        }#else
        $Jobs = (Get-SqlAgentJob -ServerInstance $Server)
        It "$Server Should not have Database Maintenance Category"{
            $Jobs.Where{$_.Category -eq'Database Maintenance'}.Count | Should Be 0
        }
        It "$Server Should not have Log Who is active Agent Job" {
        $Jobs.Where{$_.Name -eq 'Log SP_WhoisActive to Table'}.Count | Should Be 0
        }
           }#else
        }#foreach
    
    }
    Context "Surface Book" {
        BeforeAll {
             $srv = New-Object Microsoft.SQLServer.Management.SMO.Server .
        }
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
        It "Should not have a ScriptInstall Database" {
            $srv.Databases.Name.Contains('ScriptInstall')| Should Be $false
        }
        It "Should not have a Auto Install Job" {
            $Srv.JobServer.Jobs.Name.Contains('!AutoInstall DBA Scripts')| Should Be $false
        }
        It "Should not have any HTML files in Reports Folder" {
        (Get-ChildItem C:\temp\Reports\*.html).Count | Should Be 0
        }
        It "Should not have any XML files in Reports Folder" {
        (Get-ChildItem C:\temp\Reports\*.xml).Count | Should Be 0
        }
    }
} #end describe