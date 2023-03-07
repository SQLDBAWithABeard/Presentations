Describe "Make sure everything is as expected after we have run the code" -Tag After {
    BeforeAll {
        $secStringPassword = ConvertTo-SecureString -String 'dbatools.IO' -AsPlainText -Force
        [pscredential]$cred = New-Object System.Management.Automation.PSCredential ('sa', $secStringPassword)
    }
    Context "The Instance" {

        It "Should have user databases named <Name>" -TestCases @(
            @{
                Name = 'Database1'
            }
            @{
                Name = 'BeardsAreAwesome'
            } 
        ) { ($Name)
            Get-DbaDatabase -sqlInstance db -sqlcredential $cred -Database $Name | Should -Not -BeNullOrEmpty
        }
    }
    Context "The Logins" {

           $TestCases = 'Beard','Jess', 'Chrissy','Claudio','William','Gianluca','BW1','BW2','BW3' 

        It "Should have a user login named <_>" -TestCases $TestCases {
            ($_)
            Get-DbaLogin -SqlInstance db -SqlCredential $cred -Login $_ | Should -Not -BeNullOrEmpty
        }
        It "User <_> Default Database should be tempdb" -TestCases $TestCases {
            ($_)
            (Get-DbaLogin -SqlInstance db -SqlCredential $cred -Login $_ ).DefaultDatabase| Should -Not -BeNullOrEmpty -Because "This is the requirement from our standards which you can find at linktostandards"
        }
    }
}