Describe "Make sure everything is as expected before we run code" -Tag Before {
    BeforeAll {
        $secStringPassword = ConvertTo-SecureString -String 'dbatools.IO' -AsPlainText -Force
        [pscredential]$cred = New-Object System.Management.Automation.PSCredential ('sa', $secStringPassword)
    }
    Context "The databases" {
        It "Should not have any user databases" {
            Get-DbaDatabase -SqlInstance db -SqlCredential $cred
        }
        It "Should not have any user databases with a Should" {
            Get-DbaDatabase -SqlInstance db -SqlCredential $cred -ExcludeSystem | Should -BeNullOrEmpty
        }
    }
    Context "The Logins" {
        It "Should not have any User Logins" {
            Get-DbaLogin -SqlInstance db -SqlCredential $cred -ExcludeSystemLogin -ExcludeLogin '##MS_PolicyEventProcessingLogin##', '##MS_PolicyTsqlExecutionLogin##', 'BUILTIN\Administrators', 'NT AUTHORITY\NETWORK SERVICE', 'NT AUTHORITY\SYSTEM' | Should -BeNullOrEmpty
        }
    }
}