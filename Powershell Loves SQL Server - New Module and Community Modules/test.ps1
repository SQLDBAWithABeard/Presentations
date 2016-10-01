Describe "Testing NUC" {
    Context "VM State" {       
        $NUCServers ='BeardDC1','SQL2005Ser2003','SQL2008Ser2008','SQL2012Ser08AG3','SQL2012Ser2008AG1','SQL2012Ser2008AG2','SQL2014Ser2012R2','SQL2016N1','SQL2016N2','THEBEARDDNS1' 
        $NUCVMs = Get-VM -ComputerName beardnuc | Where-Object {$_.Name -in $NUCServers}
            foreach($VM in $NUCVms)
                {
                $VMName = $VM.Name
                  It "$VMName Should be Running"{
                    $VM.State | Should Be 'Running'
                  }
                }
    
    } # end context vms
    }
Describe "Demo Readiness" {
	Context "Ping test" {
		foreach ($ServerName in $NUCServers)
		{
			It "$Servername Should respond to ping" {
				(Test-Connection -ComputerName $Servername -Count 1 -Quiet -ErrorAction SilentlyContinue) | Should be $True			
			}
			
		}
	}
    Context "SQL State" {
        $SQLServers = 'SQL2005Ser2003','SQL2008Ser2008','SQL2012Ser08AG3','SQL2012Ser08AG1','SQL2012Ser08AG2','SQL2014Ser12R2','SQL2016N1','SQL2016N2'
        foreach($Server in $SQLServers)
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
        }
    
    }
    Context "Surface Book" {
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