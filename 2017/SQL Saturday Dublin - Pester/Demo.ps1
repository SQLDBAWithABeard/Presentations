Return "This is a demo beardy"

cd 'Presentations:\SQL Saturday Dublin - Pester'
. .\Get-SpeakerFace.ps1

## run before the powerpoint Rob
$Faces = (Get-SpeakerFace)
## If you forget
$faces = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json

## lets start with some simple
Import-Module Pester
Get-Module Pester 

New-Fixture -Name Get-SpeakerBeard 

## Now look in the folder
dir 

Invoke-Pester

## Not so good lets add a check if the command exists
<# 
 Add to Tests and Save
 
 $here = Split-Path -Parent $MyInvocation.MyCommand.Path
 $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
 . "$here\$sut"
 $CommandName = $sut.Replace(".ps1", '')
 Describe "Tests for the $CommandName Command" {
     It "Command $CommandName exists" {
         Get-Command $CommandName -ErrorAction SilentlyContinue | Should Not BE NullOrEmpty
     }
 } 
 #>
Invoke-Pester 
## Lets Talk context
<# 
 Add to Tests and Save
 
 $here = Split-Path -Parent $MyInvocation.MyCommand.Path
 $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
 . "$here\$sut"
 $CommandName = $sut.Replace(".ps1", '')
 Describe "Tests for the $CommandName Command" {
     It "Command $CommandName exists" {
         Get-Command $CommandName -ErrorAction SilentlyContinue | Should Not BE NullOrEmpty
     }
     Context "$CommandName Input" {
         ## For Checking parameters
 
     }
     Context "$CommandName Execution" {
         ## Ensuring the code follows the expected path
 
     }
     Context "$CommandName Output" {
         ## Probably most of tests here
     }
     
 }
#>
Invoke-Pester 
## Write a test for some inputs
## We are going to be using the Speaker page on Tugait
## We will analyse the pictures and see if there are any good beards!!
## Our command will have a speaker parameter and it should return 
## some information if there is no speaker


<#
Add to Tests and save

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
 $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
 . "$here\$sut"
 $CommandName = $sut.Replace(".ps1", '')
 Describe "Tests for the $CommandName Command" {
     It "Command $CommandName exists" {
         Get-Command $CommandName -ErrorAction SilentlyContinue | Should Not BE NullOrEmpty
     }
     Context "$CommandName Input" {
         ## For Checking parameters
         It 'When there is no speaker in the array should return a useful message' {
             Get-SpeakerBeard -Speaker 'Chrissy LeMaire' -Faces $faces | Should Be 'No Speaker with a name like that - You entered Chrissy LeMaire'
         }
 
     }
     Context "$CommandName Execution" {
         ## Ensuring the code follows the expected path
 
     }
     Context "$CommandName Output" {
         ## Probably most of tests here
     }
     
 }
#>

Invoke-Pester

## Now we have a failing test
## Lets write soem code to fix that
<#

Add to function and save


 function Get-SpeakerBeard {
         param(
         $Speaker,
 $Faces = (Get-SpeakerFace))
 
 if(($Faces.Name -match $Speaker).count -eq 0) {
     Return "No Speaker with a name like that - You entered $($Speaker)"
 }
}


#>
Invoke-Pester
## But the issue here is that we are relying on the Get-SpeakerFace function  
## to return the value and if we look at what it does we cna see that it is
## connecting to the internet - looking at the tugait website and using the 
## Microsoft Cognitive Services Faces API
## WE DONT WANT TO TEST ALL OF THOSE - ONLY our code
## So We mock
## Lets Look at what Get-SpeakerFaces returns

$Faces
$faces | gm

## So it returns a custom object
## If only we could save that to disk and return it when we needed
## This is ONE way of doing this there are others

# $faces | ConvertTo-Json -Depth 5  | out-file faces.json  ## The depth value is important here
Get-Content .\faces.json
$a = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
$a
$a | gm
Compare-Object $a $Faces
Compare-Object $a $Faces -IncludeEqual

## So how do we mock ? 

<#

Add to tests and save

 $here = Split-Path -Parent $MyInvocation.MyCommand.Path
 $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
 . "$here\$sut"
 $CommandName = $sut.Replace(".ps1", '')
 Describe "Tests for the $CommandName Command" {
     It "Command $CommandName exists" {
         Get-Command $CommandName -ErrorAction SilentlyContinue | Should Not BE NullOrEmpty
     }
     Context "$CommandName Input" {
         BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
         }
         ## For Checking parameters
         It 'When there is no speaker in the array should return a useful message' {
             Get-SpeakerBeard -Speaker 'Chrissy LeMaire'  | Should Be 'No Speaker with a name like that - You entered Chrissy LeMaire'
         }
 
     }
     Context "$CommandName Execution" {
         ## Ensuring the code follows the expected path
 
     }
     Context "$CommandName Output" {
         ## Probably most of tests here
     }
     
 }

#>

Invoke-Pester

## Now we want to do something if there is a Speaker
## We want to return the Beard value
## So our test becomes

<#

Add to test and save

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
 $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
 . "$here\$sut"
 $CommandName = $sut.Replace(".ps1", '')
 Describe "Tests for the $CommandName Command" {
     It "Command $CommandName exists" {
         Get-Command $CommandName -ErrorAction SilentlyContinue | Should Not BE NullOrEmpty
     }
     Context "$CommandName Input" {
         BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
         }
         ## For Checking parameters
         It 'When there is no speaker in the array should return a useful message' {
             Get-SpeakerBeard -Speaker 'Chrissy LeMaire' -Faces $faces | Should Be 'No Speaker with a name like that - You entered Chrissy LeMaire'
         }
 
     }
     Context "$CommandName Execution" {
         ## Ensuring the code follows the expected path
 
     }
     Context "$CommandName Output" {
         ## Probably most of tests here
                  BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
         }
         It "Should Return the Beard Value for a Speaker" {
             Get-SpeakerBeard -Speaker Jaap -Faces $faces | Should Be 0.2
         }
     }
     
 }

#>

Invoke-Pester

## Good that failed
## Now write the code to fix it
<#

Add to funciton and save

function Get-SpeakerBeard {
         param(
         $Speaker,
        $Faces = (Get-SpeakerFace)
 )
    if(($Faces.Name -match $Speaker).count -eq 0) {
         Return "No Speaker with a name like that - You entered $($Speaker)"
    }
    else {
        $Faces.Where{$_.Name -like "*$Speaker*"}.FaceAttributes.facialHair.Beard
    }
}

#>

Invoke-Pester

## What about if we want a detailed parameter which returns the Speaker Name,
## Beard Value and URL of the photo
## Lets write a test - This time we have added an assert mock called as well
# Also notice you CAN check multiple things in one It block - not saying you should 

<#

Add to tests and save

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
 $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
 . "$here\$sut"
 $CommandName = $sut.Replace(".ps1", '')
 Describe "Tests for the $CommandName Command" {
     It "Command $CommandName exists" {
         Get-Command $CommandName -ErrorAction SilentlyContinue | Should Not BE NullOrEmpty
     }
     Context "$CommandName Input" {
         BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
         }
         ## For Checking parameters
         It 'When there is no speaker in the array should return a useful message' {
             Get-SpeakerBeard -Speaker 'Chrissy LeMaire' | Should Be 'No Speaker with a name like that - You entered Chrissy LeMaire'
         }
          It 'Checks the Mock was called for Speaker Face' {
        $assertMockParams = @{
            'CommandName' = 'Get-SpeakerFace'
            'Times' = 1
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
 
     }
     Context "$CommandName Execution" {
         ## Ensuring the code follows the expected path
 
     }
     Context "$CommandName Output" {
         ## Probably most of tests here
                  BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
         }
         It "Should Return the Beard Value for a Speaker" {
             Get-SpeakerBeard -Speaker Jaap | Should Be 0.2
         }
         It "Should Return Speaker Name, Beard Value and URL if Detailed Specified" {
            $Result = (Get-SpeakerBeard -Speaker Jaap -Detailed)
            $Result.Name | Should Be 'JaapBrasser'
            $Result.Beard | Should Be 0.2
            $Result.ImageUrl | Should Be 'http://tugait.pt/2017/wp-content/uploads/2017/04/JaapBrasser-262x272.jpg'
         }
             It 'Checks the Mock was called for Speaker Face' {
        $assertMockParams = @{
            'CommandName' = 'Get-SpeakerFace'
            'Times' = 2
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
     }
     
 }

#>

Invoke-Pester

## Now write the code to pass that test 

<#

Add to function and save

 function Get-SpeakerBeard {
         param(
         $Speaker,
        $Faces = (Get-SpeakerFace),
        [switch]$Detailed)
    if(!$Faces){
     $faces = (Get-SpeakerFace -webpage $Webpage)
     }
     if(($Faces.Name -match $Speaker).count -eq 0) {
         Return "No Speaker with a name like that - You entered $($Speaker)"
     }
    else {
        if(!($detailed)){
        $Faces.Where{$_.Name -like "*$Speaker*"}.FaceAttributes.facialHair.Beard
        }
        else {
        $Faces.Where{$_.Name -like "*$Speaker*"}|Select-Object Name, @{ 
        Name       = 'Beard' 
        Expression = { 
            [decimal]$_.faceattributes.facialhair.beard 
                } 
            }, ImageURL
        }
    }
}


 #>

 Invoke-Pester

 ## Now lets suppose that we wanted to open the URL of the Image with a switch  
 ## called ShowImage which calls Start-Process to load the image
 ## we want to ensure that the code follows the correct path and calls Start-Process
 ## So we mock Start-Process as well and Assert it is called
 ## We are not worried if the URL is incorrect as we are not testing the results only the code
 
 <#

Add to tests and save

 $here = Split-Path -Parent $MyInvocation.MyCommand.Path
 $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
 . "$here\$sut"
 $CommandName = $sut.Replace(".ps1", '')
 Describe "Tests for the $CommandName Command" {
     It "Command $CommandName exists" {
         Get-Command $CommandName -ErrorAction SilentlyContinue | Should Not BE NullOrEmpty
     }
     Context "$CommandName Input" {
         BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
         }
         ## For Checking parameters
         It 'When there is no speaker in the array should return a useful message' {
             Get-SpeakerBeard -Speaker 'Chrissy LeMaire' | Should Be 'No Speaker with a name like that - You entered Chrissy LeMaire'
         }
          It 'Checks the Mock was called for Speaker Face' {
        $assertMockParams = @{
            'CommandName' = 'Get-SpeakerFace'
            'Times' = 1
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
 
     }
     Context "$CommandName Execution" {
         ## Ensuring the code follows the expected path
         BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
             Mock Start-Process {}
         }
        It 'Opens the image if ShowImage switch used' {
            Get-SpeakerBeard -Speaker Jaap -ShowImage | Should Be 0.2
        }
        It "Opens the image if ShowImage switch used and Detailed Switch" {
            $Result = (Get-SpeakerBeard -Speaker Jaap -Detailed -ShowImage)
            $Result.Name | Should Be 'JaapBrasser'
            $Result.Beard | Should Be 0.2
            $Result.ImageUrl | Should Be 'http://tugait.pt/2017/wp-content/uploads/2017/04/JaapBrasser-262x272.jpg'
         }
        It 'Checks the Mock was called for Speaker Face' {
        $assertMockParams = @{
            'CommandName' = 'Get-SpeakerFace'
            'Times' = 2
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
           It 'Checks the Mock was called for Start-Process' {
        $assertMockParams = @{
            'CommandName' = 'Start-Process'
            'Times' = 2
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
     }
     Context "$CommandName Output" {
         ## Probably most of tests here
                  BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
         }
         It "Should Return the Beard Value for a Speaker" {
             Get-SpeakerBeard -Speaker Jaap | Should Be 0.2
         }
         It "Should Return Speaker Name, Beard Value and URL if Detailed Specified" {
            $Result = (Get-SpeakerBeard -Speaker Jaap -Detailed)
            $Result.Name | Should Be 'JaapBrasser'
            $Result.Beard | Should Be 0.2
            $Result.ImageUrl | Should Be 'http://tugait.pt/2017/wp-content/uploads/2017/04/JaapBrasser-262x272.jpg'
         }
             It 'Checks the Mock was called for Speaker Face' {
        $assertMockParams = @{
            'CommandName' = 'Get-SpeakerFace'
            'Times' = 2
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
     }
     
  }

 #>

 Invoke-Pester

 
 ## Now the code to pass the test

 <# 
 
 
 function Get-SpeakerBeard {
     param(
         $Speaker,
         $faces = (Get-SpeakerFace),
         [switch]$Detailed,
         [switch]$ShowImage
        )
    # If no faces grab some    
    if(!$Faces){
     $faces = (Get-SpeakerFace)
    }
    # if no speaker tell them
    if(($Faces.Name -match $Speaker).count -eq 0) {
     Return "No Speaker with a name like that - You entered $($Speaker)"
    }
    else {
        if(!($detailed)){
            $Faces.Where{$_.Name -like "*$Speaker*"}.FaceAttributes.facialHair.Beard
        }
        else {
            $Faces.Where{$_.Name -like "*$Speaker*"}|Select-Object Name, @{
                Name       = 'Beard'
                Expression = {
                    [decimal]$_.faceattributes.facialhair.beard 
                }
            }, ImageURL
        }
        if($ShowImage){
            Start-Process $Faces.Where{$_.Name -like "*$Speaker*"}.ImageURL
        }
    }
}
  #>

  Invoke-Pester

 ## So what about if we want to list the top and bottom ranked beards (according to
 ## the Cognitive Service) We will need to write the test first


<#

Add to test and save



 $here = Split-Path -Parent $MyInvocation.MyCommand.Path
 $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
 . "$here\$sut"
 $CommandName = $sut.Replace(".ps1", '')
 Describe "Tests for the $CommandName Command" {
     It "Command $CommandName exists" {
         Get-Command $CommandName -ErrorAction SilentlyContinue | Should Not BE NullOrEmpty
     }
     Context "$CommandName Input" {
         BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
         }
         ## For Checking parameters
         It 'When there is no speaker in the array should return a useful message' {
             Get-SpeakerBeard -Speaker 'Chrissy LeMaire' | Should Be 'No Speaker with a name like that - You entered Chrissy LeMaire'
         }
          It 'Checks the Mock was called for Speaker Face' {
        $assertMockParams = @{
            'CommandName' = 'Get-SpeakerFace'
            'Times' = 1
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
 
     }
     Context "$CommandName Execution" {
         ## Ensuring the code follows the expected path
         BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
             Mock Start-Process {}
         }
        It 'Opens the image if ShowImage switch used' {
            Get-SpeakerBeard -Speaker Jaap -ShowImage | Should Be 0.2
        }
        It "Opens the image if ShowImage switch used and Detailed Switch" {
            $Result = (Get-SpeakerBeard -Speaker Jaap -Detailed -ShowImage)
            $Result.Name | Should Be 'JaapBrasser'
            $Result.Beard | Should Be 0.2
            $Result.ImageUrl | Should Be 'http://tugait.pt/2017/wp-content/uploads/2017/04/JaapBrasser-262x272.jpg'
         }
        It 'Checks the Mock was called for Speaker Face' {
        $assertMockParams = @{
            'CommandName' = 'Get-SpeakerFace'
            'Times' = 2
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
           It 'Checks the Mock was called for Start-Process' {
        $assertMockParams = @{
            'CommandName' = 'Start-Process'
            'Times' = 2
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
     }
     Context "$CommandName Output" {
         ## Probably most of tests here
                  BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
         }
         It "Should Return the Beard Value for a Speaker" {
             Get-SpeakerBeard -Speaker Jaap | Should Be 0.2
         }
         It "Should Return Speaker Name, Beard Value and URL if Detailed Specified" {
            $Result = (Get-SpeakerBeard -Speaker Jaap -Detailed)
            $Result.Name | Should Be 'JaapBrasser'
            $Result.Beard | Should Be 0.2
            $Result.ImageUrl | Should Be 'http://tugait.pt/2017/wp-content/uploads/2017/04/JaapBrasser-262x272.jpg'
         }
        It "Returns the Top 1 Ranked Beards" {
            (Get-SpeakerBeard -Top 1).beard.Count | Should Be 1
    }
            It "Returns the Bottom  1 Ranked Beards" {
            (Get-SpeakerBeard -Bottom 1).beard.Count | Should Be 1
    }
            It "Returns the Top 5 Ranked Beards" {
            (Get-SpeakerBeard -Top 5).beard.Count | Should Be 5
    }
            It "Returns the Bottom  5 Ranked Beards" {
            (Get-SpeakerBeard -Bottom 5).beard.Count | Should Be 5
    }
                 It 'Checks the Mock was called for Speaker Face' {
        $assertMockParams = @{
            'CommandName' = 'Get-SpeakerFace'
            'Times' = 6
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
     }
     
  }


#>

Invoke-Pester 

## Now write the code to ppass the test
<#

add to function and save

 function Get-SpeakerBeard {
     param(
         $Speaker,
         $Faces ,
         [switch]$Detailed,
         [switch]$ShowImage,
         [int]$Top,
         [int]$Bottom
        )
    # If no faces grab some    
    if(!$Faces){
     $faces = (Get-SpeakerFace -webpage $Webpage)
    }
    # if no speaker tell them
    if(($Faces.Name -match $Speaker).count -eq 0) {
     Return "No Speaker with a name like that - You entered $($Speaker)"
    }
    else {
        if($Top -or $Bottom){
            if ($top) { 
                $Faces | Select-Object Name, @{
                    Name       = 'Beard'
                    Expression = {
                        [decimal]$_.faceattributes.facialhair.beard 
                    }
                } | Sort-Object Beard -Descending |Select Name,Beard -First $top
            }
        
             if($bottom) { 
                 $Faces|Select-Object Name, @{
                Name       = 'Beard'
                Expression = {
                    [decimal]$_.faceattributes.facialhair.beard 
                }
            } |Sort-Object Beard -Descending |Select Name,Beard -Last $Bottom}
        }
        elseif(!($detailed)){
            $Faces.Where{$_.Name -like "*$Speaker*"}.FaceAttributes.facialHair.Beard
        }
        else {
            $Faces.Where{$_.Name -like "*$Speaker*"}|Select-Object Name, @{
                Name       = 'Beard'
                Expression = {
                    [decimal]$_.faceattributes.facialhair.beard 
                }
            }, ImageURL
        }
        if($ShowImage){
            Start-Process $Faces.Where{$_.Name -like "*$Speaker*"}.ImageURL
        }
    }
}

#>

## Making sure that the code follows good practices is easy.
## We can use Script Analyser to do this

<#

Add to tests and save


 $here = Split-Path -Parent $MyInvocation.MyCommand.Path
 $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
 . "$here\$sut"
 $CommandName = $sut.Replace(".ps1", '')
 Describe "Tests for the $CommandName Command" {
     It "Command $CommandName exists" {
         Get-Command $CommandName -ErrorAction SilentlyContinue | Should Not BE NullOrEmpty
     }
     Context "$CommandName Input" {
         BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
         }
         ## For Checking parameters
         It 'When there is no speaker in the array should return a useful message' {
             Get-SpeakerBeard -Speaker 'Chrissy LeMaire' | Should Be 'No Speaker with a name like that - You entered Chrissy LeMaire'
         }
          It 'Checks the Mock was called for Speaker Face' {
        $assertMockParams = @{
            'CommandName' = 'Get-SpeakerFace'
            'Times' = 1
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
 
     }
     Context "$CommandName Execution" {
         ## Ensuring the code follows the expected path
         BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
             Mock Start-Process {}
         }
        It 'Opens the image if ShowImage switch used' {
            Get-SpeakerBeard -Speaker Jaap -ShowImage | Should Be 0.2
        }
        It "Opens the image if ShowImage switch used and Detailed Switch" {
            $Result = (Get-SpeakerBeard -Speaker Jaap -Detailed -ShowImage)
            $Result.Name | Should Be 'JaapBrasser'
            $Result.Beard | Should Be 0.2
            $Result.ImageUrl | Should Be 'http://tugait.pt/2017/wp-content/uploads/2017/04/JaapBrasser-262x272.jpg'
         }
        It 'Checks the Mock was called for Speaker Face' {
        $assertMockParams = @{
            'CommandName' = 'Get-SpeakerFace'
            'Times' = 2
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
           It 'Checks the Mock was called for Start-Process' {
        $assertMockParams = @{
            'CommandName' = 'Start-Process'
            'Times' = 2
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
     }
     Context "$CommandName Output" {
         ## Probably most of tests here
                  BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
         }
         It "Should Return the Beard Value for a Speaker" {
             Get-SpeakerBeard -Speaker Jaap | Should Be 0.2
         }
         It "Should Return Speaker Name, Beard Value and URL if Detailed Specified" {
            $Result = (Get-SpeakerBeard -Speaker Jaap -Detailed)
            $Result.Name | Should Be 'JaapBrasser'
            $Result.Beard | Should Be 0.2
            $Result.ImageUrl | Should Be 'http://tugait.pt/2017/wp-content/uploads/2017/04/JaapBrasser-262x272.jpg'
         }
        It "Returns the Top 1 Ranked Beards" {
            (Get-SpeakerBeard -Top 1).beard.Count | Should Be 1
    }
            It "Returns the Bottom  1 Ranked Beards" {
            (Get-SpeakerBeard -Bottom 1).beard.Count | Should Be 1
    }
            It "Returns the Top 5 Ranked Beards" {
            (Get-SpeakerBeard -Top 5).beard.Count | Should Be 5
    }
            It "Returns the Bottom  5 Ranked Beards" {
            (Get-SpeakerBeard -Bottom 5).beard.Count | Should Be 5
    }
    It 'Checks the Mock was called for Speaker Face' {
        $assertMockParams = @{
            'CommandName' = 'Get-SpeakerFace'
            'Times' = 6
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
     }
     }

## Add Script Analyser Rules
            Context "Testing $commandName for Script Analyser" {
                $Rules = Get-ScriptAnalyzerRule 
                $Name = $sut.Split('.')[0]
                foreach ($rule in $rules) { 
                    $i = $rules.IndexOf($rule)
                    It "passes the PSScriptAnalyzer Rule number $i - $rule  " {
                        (Invoke-ScriptAnalyzer -Path "$here\$sut" -IncludeRule $rule.RuleName ).Count | Should Be 0 
                    }
                }
            }     
  }

#>

Invoke-Pester

## Ah we failed

# If we want to see where we failed

Invoke-ScriptAnalyzer -path .\Get-SpeakerBeard.ps1

## Now write the code to fix it

<#
Add to function and save


 function Get-SpeakerBeard {
     param(
         $Speaker,
         $Faces ,
         [switch]$Detailed,
         [switch]$ShowImage,
         [int]$Top,
         [int]$Bottom
        )
    # If no faces grab some    
    if(!$Faces){
     $faces = (Get-SpeakerFace -webpage $Webpage)
    }
    # if no speaker tell them
    if(($Faces.Name -match $Speaker).count -eq 0) {
     Return "No Speaker with a name like that - You entered $($Speaker)"
    }
    else {
        if($Top -or $Bottom){
            if ($top) { 
                $Faces | Select-Object Name, @{
                    Name       = 'Beard'
                    Expression = {
                        [decimal]$_.faceattributes.facialhair.beard 
                    }
                } | Sort-Object Beard -Descending |Select-Object Name,Beard -First $top
            }
        
             if($bottom) { 
                 $Faces|Select-Object Name, @{
                Name       = 'Beard'
                Expression = {
                    [decimal]$_.faceattributes.facialhair.beard 
                }
            } |Sort-Object Beard -Descending |Select-Object Name,Beard -Last $Bottom}
        }
        elseif(!($detailed)){
            $Faces.Where{$_.Name -like "*$Speaker*"}.FaceAttributes.facialHair.Beard
        }
        else {
            $Faces.Where{$_.Name -like "*$Speaker*"}|Select-Object Name, @{
                Name       = 'Beard'
                Expression = {
                    [decimal]$_.faceattributes.facialhair.beard 
                }
            }, ImageURL
        }
        if($ShowImage){
            Start-Process $Faces.Where{$_.Name -like "*$Speaker*"}.ImageURL
        }
    }
}



#>

Invoke-Pester

## We also need to write some good help for our function
## and Pester can help there too

## Thanks to June Blender for writing this

<#

Add to tests and save


 $here = Split-Path -Parent $MyInvocation.MyCommand.Path
 $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
 . "$here\$sut"
 $CommandName = $sut.Replace(".ps1", '')
 Describe "Tests for the $CommandName Command" {
     It "Command $CommandName exists" {
         Get-Command $CommandName -ErrorAction SilentlyContinue | Should Not BE NullOrEmpty
     }
     Context "$CommandName Input" {
         BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
         }
         ## For Checking parameters
         It 'When there is no speaker in the array should return a useful message' {
             Get-SpeakerBeard -Speaker 'Chrissy LeMaire' | Should Be 'No Speaker with a name like that - You entered Chrissy LeMaire'
         }
          It 'Checks the Mock was called for Speaker Face' {
        $assertMockParams = @{
            'CommandName' = 'Get-SpeakerFace'
            'Times' = 1
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
 
     }
     Context "$CommandName Execution" {
         ## Ensuring the code follows the expected path
         BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
             Mock Start-Process {}
         }
        It 'Opens the image if ShowImage switch used' {
            Get-SpeakerBeard -Speaker Jaap -ShowImage | Should Be 0.2
        }
        It "Opens the image if ShowImage switch used and Detailed Switch" {
            $Result = (Get-SpeakerBeard -Speaker Jaap -Detailed -ShowImage)
            $Result.Name | Should Be 'JaapBrasser'
            $Result.Beard | Should Be 0.2
            $Result.ImageUrl | Should Be 'http://tugait.pt/2017/wp-content/uploads/2017/04/JaapBrasser-262x272.jpg'
         }
        It 'Checks the Mock was called for Speaker Face' {
        $assertMockParams = @{
            'CommandName' = 'Get-SpeakerFace'
            'Times' = 2
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
           It 'Checks the Mock was called for Start-Process' {
        $assertMockParams = @{
            'CommandName' = 'Start-Process'
            'Times' = 2
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
     }
     Context "$CommandName Output" {
         ## Probably most of tests here
                  BeforeAll {
             $MockFace = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json
             Mock Get-SpeakerFace {$MockFace}
         }
         It "Should Return the Beard Value for a Speaker" {
             Get-SpeakerBeard -Speaker Jaap | Should Be 0.2
         }
         It "Should Return Speaker Name, Beard Value and URL if Detailed Specified" {
            $Result = (Get-SpeakerBeard -Speaker Jaap -Detailed)
            $Result.Name | Should Be 'JaapBrasser'
            $Result.Beard | Should Be 0.2
            $Result.ImageUrl | Should Be 'http://tugait.pt/2017/wp-content/uploads/2017/04/JaapBrasser-262x272.jpg'
         }
             It 'Checks the Mock was called for Speaker Face' {
        $assertMockParams = @{
            'CommandName' = 'Get-SpeakerFace'
            'Times' = 2
            'Exactly' = $true
        }
        Assert-MockCalled @assertMockParams 
    }
        It "Returns the Top 1 Ranked Beards" {
            (Get-SpeakerBeard -Top 1).beard.Count | Should Be 1
    }
            It "Returns the Bottom  1 Ranked Beards" {
            (Get-SpeakerBeard -Bottom 1).beard.Count | Should Be 1
    }
            It "Returns the Top 5 Ranked Beards" {
            (Get-SpeakerBeard -Top 5).beard.Count | Should Be 5
    }
            It "Returns the Bottom  5 Ranked Beards" {
            (Get-SpeakerBeard -Bottom 5).beard.Count | Should Be 5
    }
     }


## Add Script Analyser Rules
            Context "Testing $commandName for Script Analyser" {
                $Rules = Get-ScriptAnalyzerRule 
                $Name = $sut.Split('.')[0]
                foreach ($rule in $rules) { 
                    $i = $rules.IndexOf($rule)
                    It "passes the PSScriptAnalyzer Rule number $i - $rule  " {
                        (Invoke-ScriptAnalyzer -Path "$here\$sut" -IncludeRule $rule.RuleName ).Count | Should Be 0 
                    }
                }
            }

##            	
## 	.NOTES
## 		===========================================================================
## 		Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.119
## 		Created on:   	4/12/2016 1:11 PM
## 		Created by:   	June Blender
## 		Organization: 	SAPIEN Technologies, Inc
## 		Filename:		*.Help.Tests.ps1
## 		===========================================================================
## 	.DESCRIPTION
## 	To test help for the commands in a module, place this file in the module folder.
## 	To test any module from any path, use https://github.com/juneb/PesterTDD/Module.Help.Tests.ps1
## 
##     ## ALTERED FOR ONE COMMAND - Rob Sewell 10/05/2017
## 
        Describe "Test help for $commandName" {
		 # The module-qualified command fails on Microsoft.PowerShell.Archive cmdlets
	    $Help = Get-Help $commandName -ErrorAction SilentlyContinue
		# If help is not found, synopsis in auto-generated help is the syntax diagram
		It "should not be auto-generated" {
			$Help.Synopsis | Should Not BeLike '*`[`<CommonParameters`>`]*'
		}
		
		# Should be a description for every function
		It "gets description for $commandName" {
			$Help.Description | Should Not BeNullOrEmpty
		}
		
		# Should be at least one example
		It "gets example code from $commandName" {
			($Help.Examples.Example | Select-Object -First 1).Code | Should Not BeNullOrEmpty
		}
		
		# Should be at least one example description
		It "gets example help from $commandName" {
			($Help.Examples.Example.Remarks | Select-Object -First 1).Text | Should Not BeNullOrEmpty
		}
		
		Context "Test parameter help for $commandName" {
			$command = Get-Command $CommandName
			$Common = 'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable', 'OutBuffer', 'OutVariable',
			'PipelineVariable', 'Verbose', 'WarningAction', 'WarningVariable'
			
			$parameters = $command.ParameterSets.Parameters | Sort-Object -Property Name -Unique | Where-Object Name -notin $common
			$parameterNames = $parameters.Name
			$HelpParameterNames = $Help.Parameters.Parameter.Name | Sort-Object -Unique
			
			foreach ($parameter in $parameters)
			{
				$parameterName = $parameter.Name
				$parameterHelp = $Help.parameters.parameter | Where-Object Name -EQ $parameterName
				
				# Should be a description for every parameter
				It "gets help for parameter: $parameterName : in $commandName" {
					$parameterHelp.Description.Text | Should Not BeNullOrEmpty
				}
				
				# Required value in Help should match IsMandatory property of parameter
				It "help for $parameterName parameter in $commandName has correct Mandatory value" {
					$codeMandatory = $parameter.IsMandatory.toString()
					$parameterHelp.Required | Should Be $codeMandatory
				}
				
				# Parameter type in Help should match code
				It "help for $commandName has correct parameter type for $parameterName" {
					$codeType = $parameter.ParameterType.Name
					# To avoid calling Trim method on a null object.
					$helpType = if ($parameterHelp.parameterValue) { $parameterHelp.parameterValue.Trim() }
					$helpType | Should be $codeType
				}
			}
			
			foreach ($helpParm in $HelpParameterNames)
			{
				# Shouldn't find extra parameters in help.
				It "finds help parameter in code: $helpParm" {
					$helpParm -in $parameterNames | Should Be $true
				}
			}
		}
	}
     
  }
#>

Invoke-Pester

## Write the code to fix the test

## Add the help to Function and save


<#
.SYNOPSIS
Gets the Speaker Beard Ranking from the TUGAIT website

.DESCRIPTION
Analyses the Speaker pictures ont eh TUGAIT website with Microsoft Cognitive Services
and returns the analysis. Also returns the top and bottom ranked beards

.PARAMETER Speaker
The Speaker Name 

.PARAMETER Webpage
If not provided - the webpage of the Speakers

.PARAMETER Faces
A JSON object containing the image URLs fromt eh TUGAIT website

.PARAMETER Detailed
Returns the Speaker Name, Beard Ranking adn the URL of the picture

.PARAMETER ShowImage
A switch to open the URL in the default program

.PARAMETER Top
Returns the Top N speakers ranked by beard

.PARAMETER Bottom
Returns the Bottom N Speakers ranked by beard

.NOTES
Written for fun for TUGAIT
Rob Sewell 10/05/2017

.EXAMPLE 
$Faces = (Get-SpeakerFace)
Get-SpeakerBeard -Faces $faces -Speaker JaapBrasser 

Returns the beard ranking for JaapBrasser  using a Faces object returned from Get-SpeakerFace
	
.EXAMPLE
$Faces = (Get-SpeakerFace)
Get-SpeakerBeard -Faces $faces -Speaker JaapBrasser -Detailed

Returns the Speaker name, beard ranking and URL of picture beard ranking for JaapBrasser
 using a Faces object returned from Get-SpeakerFace

.EXAMPLE
$Faces = (Get-SpeakerFace)
Get-SpeakerBeard -Faces $faces -Speaker JaapBrasser -Detailed -ShowImage

Returns the Speaker name, beard ranking adn URL of picture beard ranking for JaapBrasser
and opens the URL of the image using a Faces object returned from Get-SpeakerFace

.EXAMPLE
$Faces = (Get-SpeakerFace)
Get-SpeakerBeard -Faces $faces -Top 5

Returns the top 5 speakers ranked by beard using a Faces object returned from Get-SpeakerFace

.EXAMPLE
$Faces = (Get-SpeakerFace)
Get-SpeakerBeard -Faces $faces -Bottom 5

Returns the bottom 5 speakers ranked by beard using a Faces object returned from Get-SpeakerFace
#>

## You can use the Show parameter to alter the output of the results

Invoke-Pester -Show None
Invoke-Pester -Show Failed
Invoke-Pester -Show Fails
invoke-Pester -Show Summary
Invoke-Pester -Show Header

## You can return the results as an XML file for 
## consumption by another system

Invoke-Pester -Show Summary,Header -OutputFile c:\temp\PesterResults.xml -OutputFormat NUnitXml
ii C:\temp\PesterResults.xml

## or you can save them to a variable with the PassThru Parameter

$PesterResults = Invoke-Pester -Show Summary -PassThru

$PesterResults

$PesterResults.TestResult

## Now lets look at the function results for fun

Get-SpeakerBeard -Faces $faces -Speaker JaapBrasser 
Get-SpeakerBeard -Faces $faces -Speaker JaapBrasser -Detailed
Get-SpeakerBeard -Faces $faces -Speaker JaapBrasser -ShowImage
## AWWWWWWWWWW

## THANK YOU Jaap For all of your Help with this presentation

## Who has the Top Ranked Beard

Get-SpeakerBeard -Faces $faces -Top 5

## Who has the Lowest Ranked Beard ?

Get-SpeakerBeard -Faces $faces -Bottom 5

## WHAT ????????????????????????????????????????? :-)

Get-SpeakerBeard -Faces $faces -Speaker RobSewell -Detailed
Get-SpeakerBeard -Faces $faces -Speaker RobSewell -ShowImage

$faces.Where{$_.Name -eq 'JaapBrasser'}.FaceAttributes
$faces.Where{$_.Name -eq 'RobSewell'}.FaceAttributes


## Just for fun

$url = 'https://newsqldbawiththebeard.files.wordpress.com/2017/04/wp_20170406_07_31_20_pro.jpg'

$jsonBody = @{url = $url} | ConvertTo-Json
$apiUrl = "https://westeurope.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false&returnFaceAttributes=age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,occlusion,accessories,blur"
$apiKey = $Env:MS_Faces_Key
    $headers = @{ "Ocp-Apim-Subscription-Key" = $apiKey }
    $analyticsResults = Invoke-RestMethod -Method Post -Uri $apiUrl -Headers $headers -Body $jsonBody -ContentType "application/json"  -ErrorAction Stop
    $analyticsResults 
    $analyticsResults[0] | fl
    $analyticsResults[0].faceAttributes | select * |fl
    $analyticsResults[0].faceAttributes.facialhair.beard

    ii $url

## I DO Have the Top Beard ;-)