
cd Presentations:\ 

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
        It "Should have One PowerShell ISE Process" {
            #(Get-Process powershell_ise -ErrorAction SilentlyContinue).Count | Should Be 1
        }
        It "Shoudl have Code Insiders Open" {
             (Get-Process 'Code - Insiders'  -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        }
        It "Should have PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Not BeNullOrEmpty 
        }
       It "Should have One PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Not BeNullOrEmpty 
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
            (Get-Location).Path | Should Be 'Presentations:\SQL Saturday Holland - Intro To Pester'
        }
        It "Should be running as rob-xps\mrrob" {
            whoami | Should Be 'rob-xps\mrrob'
        }
        It "Bolton should be running"{
            (Get-VM -Name Bolton).State | Should Be 'Running'
        }
        It "Bolton Should respond to ping" {
            Test-Connection Bolton -Count 1 -Quiet -ErrorAction SilentlyContinue |Should Be $true
        }
        It "Should have Pester version 4.0.3 imported" {
            (Get-Module Pester).Version | Should Be '4.0.3'
        }
        It "Should have dbatools version 0.9.25 imported" {
            (Get-Module dbatools).Version | Should Be '0.9.25'
        }
    }
}

Describe "Testing for Demo"{
    It "Should have DNS Servers for correct interface - not if v6" {
        (Get-DnsClientServerAddress -InterfaceAlias 'vEthernet (Beard Internal)').Serveraddresses | Should Be @('10.0.0.1')
    }
    It "Should have correct gateway for alias - not if v6 "{
        (Get-NetIPConfiguration -InterfaceAlias 'vEthernet (Beard Internal)').Ipv4DefaultGateway.NextHop | Should Be '0.0.0.0'
    }
}