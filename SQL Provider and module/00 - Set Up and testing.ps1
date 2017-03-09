## SQL Provider Set up and test


<#

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

        $NUCServers = 'BeardDC1','BeardDC2','BeardLinuxVNext','SQL2005Ser2003','SQL2012Ser08AG3','SQL2012Ser2008AG1','SQL2012Ser2008AG2','SQL2014Ser2012R2','SQL2016N1','SQL2016N2','SQL2016N3','SQLVnextN1','SQLvNextN2','THEBEARDDNS1'
        $NUCVMs = Get-VM -ComputerName beardnuc | Where-Object {$_.Name -in $NUCServers}
            foreach($VM in $NUCVms)
                {
                $vm | Start-VM
                }

#>

## Test before presentation
Describe "Testing for Presentation" {
    Context "Rob-XPS" {
        It "Should have One PowerShell ISE Process" {
            (Get-Process powershell_ise -ErrorAction SilentlyContinue).Count | Should Be 1
        }
        It "Should have PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Be 1
        }
        It "Should have the correct PowerPoint Presentation Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).MainWindowTitle| Should Be 'Presentation1 - PowerPoint'
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
    }
    Context "Rob-XPS SQL" {
        BeforeAll {
             $srv = New-Object Microsoft.SQLServer.Management.SMO.Server .
        }
        It "DBEngine is running" {
            (Get-Service MSSQLSERVER).Status | Should Be Running
        }
        It "SQL Server Agent is running" {
            (Get-Service SQLSERVERAGENT).Status | Should Be Running
        }
        It "DAVE DBEngine is running" {
            (Get-Service mssql*Dave).Status | Should Be Running
        }
        It "DAVE Agent is running" {
            (Get-Service sqlagent*dave).Status | Should Be Running
        }
        It "Should not have any HTML files in Reports Folder" {
        (Get-ChildItem C:\temp\Reports\*.html).Count | Should Be 0
        }
        It "Should not have any XML files in Reports Folder" {
        (Get-ChildItem C:\temp\Reports\*.xml).Count | Should Be 0
        }
    }
    Context "VM State" {       
        $NUCServers = 'BeardDC1','BeardDC2','BeardLinuxVNext','SQL2005Ser2003','SQL2012Ser08AG3','SQL2012Ser2008AG1','SQL2012Ser2008AG2','SQL2014Ser2012R2','SQL2016N1','SQL2016N2','SQL2016N3','SQLVnextN1','SQLvNextN2','THEBEARDDNS1'
        $NUCVMs = Get-VM -ComputerName beardnuc | Where-Object {$_.Name -in $NUCServers}
            foreach($VM in $NUCVms)
                {
                $VMName = $VM.Name
                  It "$VMName Should be Running"{
                    $VM.State | Should Be 'Running'
                  }
			    }

    
    } # end context vms
    Context "THEBEARD_Domain" {
            $NUCServers ='BeardDC2','LinuxVvNext','SQL2005Ser2003','SQL2012Ser08AG3','SQL2012Ser08AG1','SQL2012Ser08AG2','SQL2014Ser12R2','SQL2016N1','SQL2016N2','SQL2016N3','SQLVnextN1','SQLvNextN2','THEBEARDDNS1'
            foreach($VM in $NUCServers)
                {
                                 It "$VM Should respond to ping" {
				(Test-Connection -ComputerName $VM -Count 1 -Quiet -ErrorAction SilentlyContinue) | Should be $True
				}
                }
    }
    Context "SQL State" {
        $SQLServers = 'SQL2005Ser2003','SQL2012Ser08AG3','SQL2012Ser08AG1','SQL2012Ser08AG2','SQL2014Ser12R2','SQL2016N1','SQL2016N2','SQL2016N3','SQLVnextN1','SQLvNextN2'
        foreach($Server in $SQLServers)
        {
          $DBEngine = Get-service -ComputerName $Server -Name MSSQLSERVER
           It "$Server  DBEngine should be running" {
                $DBEngine.Status | Should Be 'Running'
            }
           It "DBEngine Should be Auto Start" {
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
    
    }
}