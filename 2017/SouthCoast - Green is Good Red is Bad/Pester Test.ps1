Describe "Testing XPS" {
  Context "XPS" {
        It "DBEngine is running" {
            (Get-Service mssqlserver).Status | Should Be Running
        }
        It "SQL Server Agent is running" {
            (Get-Service sqlserveragent).Status | Should Be Running
        }
        It "Bolton DBEngine is running" {
            (Get-Service mssql*Bolton).Status | Should Be Running
        }
        It "Bolton Agent is running" {
            (Get-Service sqlagent*Bolton).Status | Should Be Running
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
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).MainWindowTitle| Should Be 'Green Is Good - Red is Bad.pptx - PowerPoint'
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
        It "Bolton should be running"{
            (Get-VM -Name Bolton).State | Should Be 'Running'
        }
        It "Bolton Should respond to ping" {
            Test-Connection Bolton -Count 1 -Quiet -ErrorAction SilentlyContinue |Should Be $true
        }
        It "Should have Pester version 4.1.1 imported" {
            (Get-Module Pester).Version | Should Be '4.1.1'
        }
        It "Should have dbatools imported" {
            (Get-Module dbatools).Version | Should Be '0.9.170'
        }
    }
}

Describe "Testing for Demo"{
    It "Should have DNS Servers for correct interface - not if v6" {
        (Get-DnsClientServerAddress -InterfaceAlias 'WiFi').Serveraddresses | Should Be @('192.168.1.1')
    }
    It "Should have correct gateway for alias - not if v6 "{
        (Get-NetIPConfiguration -InterfaceAlias 'WiFi').Ipv4DefaultGateway.NextHop | Should Be '192.168.1.1'
    }
}