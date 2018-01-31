Return "This is a demo beardy"

cd 'Presentations:\South Coast Developers UG'

Invoke-Pester .\Pester-Test-Demo.ps1

. .\Get-SpeakerFace.ps1

## run before the powerpoint Rob

$SpeakerFaces = Get-SpeakerFace
## If you forget
$SpeakerFaces = (Get-Content faces.JSON) -join "`n" | ConvertFrom-Json

## lets start with some simple
Import-Module Pester
Get-Module Pester 

New-Fixture -Name Get-SpeakerBeard 

## Now look in the folder
dir 

Invoke-Pester

## Open Get-Speakerbeard and Get-SpeakkerBeard.Tests

## Not so good lets add a check if the command exists

Get-Content -Path .\01-Pester.ps1 | Set-Content .\Get-SpeakerBeard.Tests.ps1 -Force

Invoke-Pester 

# Excellent the command exists :-)

## Lets Talk context

Get-Content -Path .\02-Pester.ps1 | Set-Content .\Get-SpeakerBeard.Tests.ps1 -Force

# Look in the Tests file

Invoke-Pester 

## Write a test for some inputs
## We are going to be using the Speaker page on Tugait
## We will analyse the pictures and see if there are any good beards!!
## Our command will have a speaker parameter and it should return 
## some information if there is no speaker

Get-Content -Path .\03-Pester.ps1 | Set-Content .\Get-SpeakerBeard.Tests.ps1 -Force

# Look in the Tests file

Invoke-Pester

## Now we have a failing test
## Lets write some code to fix that

Get-Content -Path .\01-SpeakerBeard.ps1 | Set-Content .\Get-SpeakerBeard.ps1 -Force

# Look in Get-SpeakerBeard

Invoke-Pester

## That is the process that is all that you need to know!!!

## Write a test for your code
## Run the test to make sure it fails
## Write the code to pass the test
## Run test to make sure code passes


## But the issue here is that we are relying on the Get-SpeakerFace function  
## to return the value and if we look at what it does we can see that it is
## connecting to the internet - looking at the tugait website and using the 
## Microsoft Cognitive Services Faces API

## Lets turn the wifi off

Invoke-Pester

# We havent changed any code BUT OUR TEST FAILED


## WE DONT WANT TO TEST ANYTHING external - ONLY our code
## So We mock
## Lets Look at what Get-SpeakerFaces returns

$SpeakerFaces
$SpeakerFaces.Where{$_.Name -eq 'JaapBrasser'} | ConvertTo-Json
$SpeakerFaces | Get-Member

## So it returns a custom object
## If only we could save that to disk and return it when we needed
## This is ONE way of doing this there are others

# $faces = Get-SpeakerFace
# $faces | ConvertTo-Json -Depth 5  | out-file faces.json  ## The depth value is important here

## open the faces.json

## So how do we mock ? 

Get-Content -Path .\04-Pester.ps1 | Set-Content .\Get-SpeakerBeard.Tests.ps1 -Force

# Look in the Tests file

Invoke-Pester

# So we are now only testing our code without any external dependancies :-)

# Turn Wifi back on here Rob - Audience - Please REMIND Rob so he doesnt look confused later :-)

## Now we want to do something if there is a Speaker
## We want to return the Beard value

## Write a test

Get-Content -Path .\05-Pester.ps1 | Set-Content .\Get-SpeakerBeard.Tests.ps1 -Force

## look in test file

Invoke-Pester

## Good that failed
## Now write the code to fix it

Get-Content -Path .\02-SpeakerBeard.ps1 | Set-Content .\Get-SpeakerBeard.ps1 -Force

## Run the test - Yep you will have to get into the habit of following this process!!

Invoke-Pester

## What about if we want a detailed parameter which returns the Speaker Name,
## Beard Value and URL of the photo
## Lets write a test - This time we have added an assert mock called as well
# Also notice you CAN check multiple things in one It block - not saying you should 

## Write a test

Get-Content -Path .\06-Pester.ps1 | Set-Content .\Get-SpeakerBeard.Tests.ps1 -Force

## look in test file

Invoke-Pester

## Good that failed

## Now write the code to pass that test 

Get-Content -Path .\03-SpeakerBeard.ps1 | Set-Content .\Get-SpeakerBeard.ps1 -Force

## look at the function

## Run the test

Invoke-Pester

 ## Now lets suppose that we wanted to open the URL of the Image with a switch  
 ## called ShowImage which calls Start-Process to load the image
 ## we want to ensure that the code follows the correct path and calls Start-Process
 ## So we mock Start-Process as well and Assert it is called
 ## We are not worried if the URL is incorrect as we are not testing the results only the code

## Write a test

Get-Content -Path .\07-Pester.ps1 | Set-Content .\Get-SpeakerBeard.Tests.ps1 -Force

## look in test file

Invoke-Pester

## Good that failed

## Now write the code to pass that test 

Get-Content -Path .\04-SpeakerBeard.ps1 | Set-Content .\Get-SpeakerBeard.ps1 -Force

## look at the function

## Run the test

Invoke-Pester

 ## So what about if we want to list the top and bottom ranked beards (according to
 ## the Cognitive Service) We will need to write the test first

## Write a test

Get-Content -Path .\08-Pester.ps1 | Set-Content .\Get-SpeakerBeard.Tests.ps1 -Force

## look in test file

Invoke-Pester

## Good that failed

## Now write the code to pass that test 

Get-Content -Path .\05-SpeakerBeard.ps1 | Set-Content .\Get-SpeakerBeard.ps1 -Force

## look at the function

## Run the test

Invoke-Pester

## Making sure that the code follows good practices is easy.
## We can use Script Analyser to do this

## Write a test

Get-Content -Path .\09-Pester.ps1 | Set-Content .\Get-SpeakerBeard.Tests.ps1 -Force

## look in test file

Invoke-Pester

## Ah we failed - Someone is not following best practices :-)

## You can use the Show parameter to alter the output of the results

Invoke-Pester -Show None
Invoke-Pester -Show Failed
Invoke-Pester -Show Fails
invoke-Pester -Show Summary
Invoke-Pester -Show Header

# If we want to see where we failed

Invoke-ScriptAnalyzer -path .\Get-SpeakerBeard.ps1

## Now write the code to pass that test 

Get-Content -Path .\06-SpeakerBeard.ps1 | Set-Content .\Get-SpeakerBeard.ps1 -Force

## Run the test

Invoke-Pester -Show Summary

## We also need to write some good help for our function
## and Pester can help there too

## Thanks to June Blender for writing this

## Write a test

Get-Content -Path .\10-Pester.ps1 | Set-Content .\Get-SpeakerBeard.Tests.ps1 -Force

## look in test file

Invoke-Pester -Show Fails

## Good that failed

## Now write the code to pass that test 

Get-Content -Path .\07-SpeakerBeard.ps1 | Set-Content .\Get-SpeakerBeard.ps1 -Force

## look at the function

## Run the test

Invoke-Pester -Show Fails

. .\Get-SpeakerBeard.ps1

## Now our users can support themselves and not keep disturbing us!!

Get-Help Get-SpeakerBeard

Get-Help Get-SpeakerBeard -Detailed

Get-Help Get-SpeakerBeard -Examples


## You can return the results as an XML file for 
## consumption by another system

Invoke-Pester -Show Summary,Header -OutputFile c:\temp\PesterResults.xml -OutputFormat NUnitXml
# create new file in VS Code
$psEditor.Workspace.NewFile()
# Results into new file
Get-Content C:\temp\PesterResults.xml | Out-CurrentFile

## or you can save them to a variable with the PassThru Parameter

$PesterResults = Invoke-Pester -Show Summary -PassThru

$PesterResults

$PesterResults.TestResult

## or convert to json

$PesterResults.TestResult | ConvertTo-Json -Depth 10 | Out-File C:\temp\PesterResults.json 

## and create some pretty Power Bi :-)

Start-Process -FilePath .\Pester_Results.pbix

## Lets look at some New Pre-Release Features

## Switch to PowerShell Core 

## Lets try the latest Pre-Release

## this requires the latest version of PowerShellGet installed on PowerShell v6 but on earlier versions

## In An Admin session

##  Install-Module  PowerShellGet 

## Install-Module -Name Pester -AllowPrerelease

Import-Module Pester

## Check it is the latest version

Get-Module Pester

Import-Module C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules\SmbShare\SmbShare.psd1

Get-Module Pester

Get-Command -Module Pester

$Speaker = 'Rob'

# $Speaker = 'James'

Describe "The Speaker" {
    Context "Facial Appearance" {
        It "The Speaker Should have a Beard" {
            $Speaker | Should -Be 'Rob' -Because "Beards Are Awesome"
        }
    }
}

Describe "My System" {
    Context "Server" {
        It "Should be using XP SP3" {
            (Get-CimInstance -ClassName win32_operatingsystem).Version | Should -Be '5.1.2600' -Because "We have failed to bother to update the App and it only works on XP"
        }
        It "Should be running as rob-xps\mrrob" {
            whoami | Should -Be 'rob-xps\mrrob' -Because "This is the user with the permissions"
        }
        It "Should have SMB1 enabled" {
            (Get-SmbServerConfiguration).EnableSMB1Protocol | Should -BeTrue -Because "We don't care about the risk"
        }
    }
}

## Now lets look at the function results for fun

Get-SpeakerBeard -Faces $SpeakerFaces -Speaker JaapBrasser 
Get-SpeakerBeard -Faces $SpeakerFaces -Speaker JaapBrasser -Detailed
Get-SpeakerBeard -Faces $SpeakerFaces -Speaker JaapBrasser -ShowImage
## AWWWWWWWWWW

## THANK YOU Jaap For all of your Help with this presentation

## Who has the Top Ranked Beard

Get-SpeakerBeard -Faces $SpeakerFaces -Top 5

## Who has the Lowest Ranked Beard ?

Get-SpeakerBeard -Faces $SpeakerFaces -Bottom 5

## WHAT ????????????????????????????????????????? :-)

Get-SpeakerBeard -Faces $SpeakerFaces -Speaker RobSewell 
Get-SpeakerBeard -Faces $SpeakerFaces -Speaker RobSewell -Detailed
Get-SpeakerBeard -Faces $SpeakerFaces -Speaker RobSewell -ShowImage



## Just for fun

$url = 'https://newsqldbawiththebeard.files.wordpress.com/2017/04/wp_20170406_07_31_20_pro.jpg'
$jsonBody = @{url = $url} | ConvertTo-Json
#$apiUrl = "https://westus.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false&returnFaceAttributes=age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,occlusion,accessories,blur"
$apiUrl = "https://westeurope.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false&returnFaceAttributes=age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,occlusion,accessories,blur"
$apiKey = $Env:MS_Faces_Key
    $headers = @{ "Ocp-Apim-Subscription-Key" = $apiKey }
    $analyticsResults = Invoke-RestMethod -Method Post -Uri $apiUrl -Headers $headers -Body $jsonBody -ContentType "application/json"  -ErrorAction Stop
    $analyticsResults 
    $VerbosePreference = 'Continue'
    ## Lets look at the face
    $analyticsResults[0] | fl

    ## Bit more detail
    $analyticsResults[0].faceAttributes | select * |fl

    ## What is the Beard Score?
    Write-Verbose "The Beard Score in this picture is"
    $analyticsResults[0].faceAttributes.facialhair.beard
    $VerbosePreference = 'SilentlyContinue'
    Start-Process $url

## I DO Have the Top Beard ;-)