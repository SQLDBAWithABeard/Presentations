
Describe "Network Settings" {
    It "Should have correct adapter" {
        (Get-NetAdapter -ErrorAction SilentlyContinue ).Name -contains 'Wifi' | Should Be $true
    }
    It "Should have the correct address" {
        (Get-NetIPAddress -InterfaceAlias 'WiFi'  -ErrorAction SilentlyContinue).Where{$_.AddressFamily -eq 'Ipv4'}.Ipaddress | Should be '192.168.1.21'
    }
    It "Should have the correct DNS Server" {
      (Get-DnsClientServerAddress -InterfaceAlias 'WiFi' -AddressFamily IPv4).ServerAddresses | Should Be @('192.168.1.1')
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
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).MainWindowTitle| Should Be 'DataMinds- Introduction to Pester - PowerPoint'
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
            (Get-Location).Path | Should Be 'Presentations:\DataMinds - Intro To Pester'
        }
        It "Should be running as rob-xps\mrrob" {
            whoami | Should Be 'rob-xps\mrrob'
        }
    }
    Context "Setup" {
        It "http://tugait.pt/2017/speakers/ should exist and be contactable" {
            Remove-Variable Result -ErrorAction SilentlyContinue
            $Url = 'http://tugait.pt/2017/speakers/'
            try {
                $result = Invoke-WebRequest -Uri $URL -DisableKeepAlive -UseBasicParsing -Method Head -ErrorAction SilentlyContinue
            }
            catch [System.Net.WebException] {
                Switch ($_.Exception.Message) {
                    'The remote server returned an error: (404) Not Found.' {
                        $result = "URL does not exist 404"
                    }
                    default{
                        $result = "An error occured"
                    }
                }
            }
            $result.StatusCode | Should BeExactly 200
        }
        It "should have the correct API Key for faces"{
            $Env:MS_Faces_Key.Substring($Env:MS_Faces_Key.Length -5) | Should Be '48ea9'
        }
        It "Should Not have the Beard Analysis module loaded" {
            Get-Module BeardAnalysis | Should BeNullOrEmpty 
        }
        It "Should Not have the Get-SpeakerBeard command loaded" {
            Get-Command Get-SpeakerBeard -ErrorAction SilentlyContinue | should BeNullOrEmpty
        }
        iT "Get-SpeakerBeard.ps1 should not exist"{
            Test-Path 'Presentations:\DataMinds - Intro To Pester\Get-SpeakerBeard.ps1' | Should Be $false
        }
        iT "Get-SpeakerBeard.Tests.ps1 should not exist"{
            Test-Path 'Presentations:\DataMinds - Intro To Pester\Get-SpeakerBeard.Tests.ps1' | Should Be $false
        }
    }
}