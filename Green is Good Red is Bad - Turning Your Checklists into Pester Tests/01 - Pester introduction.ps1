## Do I have Pester ?
Get-Module Pester

## Get the module
Find-Module Pester | Install-Module

## or follow the instructions here http://www.powershellmagazine.com/2014/03/12/get-started-with-pester-powershell-unit-testing-framework/

## SHOULD OPERATORS - Highlight and Run Rob - Theres more below

Describe "We should, so shall we look at the Should operators" {
    Context "The same and bigger and smaller - or not" {

        $SQLservice = Get-Service MSSQLSERVER
        $srv = New-Object Microsoft.SqlServer.Management.Smo.Server ROB-SURFACEBOOK

        It "Is the Service Running? Status should be Running" {
            $SQLservice.Status | Should Be "Running" # Test will pass
            }

        It "The Server Collation should be EXACTLY Latin1_General_CI_AS not Latin1_General_ci_AS" {
            $srv.Collation | Should BeExactly "Latin1_General_CI_AS" # Test will pass
            }
        It "Use NOT - Service Start Mode should not be Automatic (Delayed Start)" {
            $srv.ServiceStartMode | Should Not Be "Automatic (Delayed Start)" # Test will pass
            }
        It "Do we have all of the alerts?" {
            $srv.JobServer.Alerts.Count | Should BeGreaterThan 12 # Test will pass
        }
        It "Are all of the Alerts enabled?" {
            $srv.JobServer.Alerts.Where{$_.IsEnabled -eq $false}.Count | Should BeLessThan 1
        }
        It "All databases are online - You can use NOT" {
            $srv.Databases.Where{$_.Status -ne 'Normal'}.Count | Should Not BeGreaterThan 0
        }
        }#End Context
        Context "I 'like' to 'match'" {
    
            $srv = New-Object Microsoft.SqlServer.Management.Smo.Server ROB-SURFACEBOOK

        It "Server name should be like Rob* .Use the Like assertion to check for wildcards" {
            $srv.NetName| Should BeLike 'Rob*'
        }
        It "Server name should be exactly like ROB* Use the Like assertion to exactly check for wildcards" {
            $srv.NetName| Should BeLikeExactly 'ROB*'
        }
        It "Servername should end with Book Finds a suitable match using regex" {
            $srv.Name | Should Match ".Book"
        }
        It "Servername should end exaclty with BOOK Finds a suitable match using regex" {
            $srv.Name | Should Match ".BOOK"
        }
        }#End Context

        Context "What does $($srv.Name) contain? Doesn't work quite as you think it should" {

        $srv = New-Object Microsoft.SqlServer.Management.Smo.Server ROB-SURFACEBOOK
        $Errorlog = $srv.ErrorLogPath + '\ERRORLOG'
        It "Error Log contains SQL Server is Ready - Contains works with Files" {
            
             $Errorlog | Should Contain "SQL Server is now ready for client connections"
        }

        It "Error Log shows CHECKDB finished without errors notice the .* any number of any character" {
            $Errorlog | Should Contain "CHECKDB for database.*finished without errors"
            ## NOT Checking if any did not pass 
        }
        It "Logins contain THEBEARD\Rob" {
            ## $srv.logins.Name | Should MatchExactly 'THEBEARD\\ROB'  ## This does not work Pester doesnt match arrays using Contains
            $srv.logins.Name -contains 'THEBEARD\Rob' |Should Be $true
            }
        It "$($srv.Name) has an operator - using BeNullOrEmpty and NOT" {
            $srv.JobServer.Operators | Should Not BeNullOrEmpty
        }
        } # End Context
    }# End Describe


    ## Now lets make it fail
    <#
        Get-Service MSSQLSERVER | Stop-Service -force
    #>

    ## why do the two match tests pass?

    ## Its because of the SMO object you created in the test

     $srv = New-Object Microsoft.SqlServer.Management.Smo.Server AStupidNameThatDoesntexist

     $srv.Name -match '.exist'

    ## Sideways tip, always validate your SMO Server objects for failed connections
    ## I use the version property

    $srv.ConnectionContext.ConnectTimeout = 1 # so we dont have to wait

    if($null -eq $srv.version)
    {
        Write-Warning "Uh-Oh The Beard is sad. Can't connect to $($srv.Name)"
    }

    ## Doing a presentation?
    ## Write a Pester Check 

    psEdit 'Presentations:\Green is Good Red is Bad - Turning Your Checklists into Pester Tests\00 - Setup and Pester Test.ps1'