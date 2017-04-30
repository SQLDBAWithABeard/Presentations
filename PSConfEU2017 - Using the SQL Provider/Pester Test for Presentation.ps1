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

try
{
    Start-Process powershell.exe -ArgumentList '-noprofile -command Get-Service MS*CTP2*,SQLAgent*CTP2 | Start-Service' -Verb runas
}
catch
{
    Write-Warning "FAILED to start SQL"
}

get-module dbatools | remove-module -ea silentlycontinue
import-module git:\dbatools\dbatools.psd1
#>

Describe "Testing NUC" {
    Context "VM State" {       
        $NUCServers = 'BeardDC1','BeardDC2','LinuxVNextCTP14','SQL2005Ser2003','SQL2012Ser08AG3','SQL2012Ser08AG1','SQL2012Ser08AG2','SQL2014Ser12R2','SQL2016N1','SQL2016N2','SQL2016N3','SQLVnextN1','SQLvNextN2'
        $NUCVMs = Get-VM -ComputerName beardnuc | Where-Object {$_.Name -in $NUCServers}
            foreach($VM in $NUCVms)
                {
                $VMName = $VM.Name
                  It "$VMName Should be Running"{
                    $VM.State | Should Be 'Running'
                  }
			    }
    }
Context "THEBEARD_Domain" {
            $NUCServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.State -eq 'Running'}).Name
            foreach($VM in $NUCServers)
                {
                                 It "$VM Should respond to ping" {
				(Test-Connection -ComputerName $VM -Count 1 -Quiet -ErrorAction SilentlyContinue) | Should be $True
				}
                }
            It "Domain Controllers should be running" {
                ($NUCServers -match 'DC').Count | Should Be 2
            }
    }

    Context "SQL State" {
        $SQLServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL*' -and $_.State -eq 'Running'}).Name
        foreach($Server in $SQLServers)
        {
          $DBEngine = Get-service -ComputerName $Server -Name MSSQLSERVER -ErrorAction SilentlyContinue
           It "$Server  DBEngine should be running" {
                $DBEngine.Status | Should Be 'Running'
            }
           It "$Server DBEngine Should be Auto Start" {
            $DBEngine.StartType | Should be 'Automatic'
           }
              $Agent= Get-service -ComputerName $Server -Name SQLSERVERAGENT  -ErrorAction SilentlyContinue
              It "$Server Agent should be running" {
                  $Agent.Status | Should Be 'Running'
           }
           It "$Server Agent Should be Auto Start" {
            $Agent.StartType | Should be 'Automatic'
           }
        }
    
    }
}

Describe "Testing XPS" {
  Context "XPS" {
        It "DBEngine is running" {
            (Get-Service mssqlserver -ErrorAction SilentlyContinue).Status | Should Be Running
        }
        It "SQL Server Agent is running" {
            (Get-Service sqlserveragent -ErrorAction SilentlyContinue).Status | Should Be Running
        }
        It "DAVE DBEngine is running" {
            (Get-Service mssql*Dave -ErrorAction SilentlyContinue).Status | Should Be Running
        }
        It "DAVE Agent is running" {
            (Get-Service sqlagent*dave -ErrorAction SilentlyContinue).Status | Should Be Running
        }
    }
      

} #end describe
Describe "Testing for Presentation" {
    Context "Rob-XPS" {
        It "Should have One PowerShell ISE Process" {
            (Get-Process powershell_ise -ErrorAction SilentlyContinue).Count | Should Be 1
        }
        It "Shoudl have Code Insiders Open" {
             (Get-Process 'Code - Insiders'  -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        }
        It "Should have PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Be 1
        }
        It "Should have the correct PowerPoint Presentation Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).MainWindowTitle| Should Be 'Using the SQL Provider - PowerPoint'
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
}