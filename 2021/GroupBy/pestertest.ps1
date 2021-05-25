Describe "Testing NUC is ready for presentation" {

    Context "Hosts" {
        $Hosts = @(
            @{
                Name = 'beardlinux'
            },
            @{
                Name = 'beardlinux2'
            },
            @{
                Name = 'beardlinux3'
            }
        )
        It "<name> should be available " -TestCases $Hosts {
            param($Name)
            (Test-NetConnection $Name -Port 22).TcpTestSucceeded | Should -BeTrue -Because "You need all the hosts available and $Name is not"
        }
    }
    Context "Containers" {

        It "Container <containername> in pod <podname> on node <hostname> should be ready" -TestCases $Containers {
            param($nodename,$podname,$containername,$containerready)
            $containerready | Should -Be 'True'
        }
    }
    Context "SQL Managed Instance" {
        It "Should Connect" {
            $ConnectionTest.ConnectSuccess | Should -BeTrue -Because "We Should be able to connect to the instance"
        }
    }
    Context "Desktop Files" {
        It "The output directory should exist" {
            Test-Path C:\temp\xlsx |Should -BeTrue -Because 'We need a place to have the files'
        }
        It "The output directory should be empty"{
            Get-ChildItem C:\temp\xlsx | Should -BeNullOrEmpty
        }
    }

}