Return "This is a demo beardy"
## lets start with some simple
Import-Module Pester
Get-Module Pester 
cd 'presentations:\TUGAIT 2017 Pester'
. .\Get-SpeakerFace.ps1
New-Fixture -Name Get-SpeakerBeard 
cd TUGATest

$Faces = (Get-SpeakerFace)
## Now look in the folder
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

$faces | ConvertTo-Json -Depth 5  | out-file faces.json  ## The depth value is important here
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

 ## So what about if we want to list the top and bottom ranked beards (according to
 ## the Cognitive Service) We will need to 

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





<#

add to function and save
 function Get-SpeakerBeard {
     param(
         $Speaker,
         $Webpage = (Invoke-WebRequest http://tugait.pt/2017/speakers/),
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

