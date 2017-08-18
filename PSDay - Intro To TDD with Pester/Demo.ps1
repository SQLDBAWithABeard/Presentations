Return "This is a demo beardy"
## Start with a Plaster Module
## This is a template framework to reduce you from creating all the usual scaffolding
## This is mine

cd Git:\PlasterTemplate
code-insiders . 

## Then create your module

$ModuleName = "BeardAnalysis"
$Description = "This is a demo module for demoing Plaster and TDD with Pester and CI with VSTS to the PowerShell Gallery"

$plaster = @{
    TemplatePath = "GIT:\PlasterTemplate" #(Split-Path $manifestProperties.Path)
    DestinationPath = "Git:\$ModuleName"
    FullName = "Rob Sewell"
    ModuleName = $ModuleName
    ModuleDesc = $Description
    Version = "0.9.0"
    GitHubUserName = "SQLDBAWithABeard"
    GitHubRepo = $ModuleName
    }
    If(!(Test-Path $plaster.DestinationPath))
    {
    New-Item -ItemType Directory -Path $plaster.DestinationPath
    }
    Invoke-Plaster @plaster -Verbose

    ## lets have a look what has been created

    cd Git:\$ModuleName
    code-insiders . 

    ## Publish to GitHub using this function from Jeff Hicks to create a repo

    . Git:\Functions\New-GitHubRepository.ps1

    $Repo = New-GitHubRepository -Name $ModuleName -Description $Description

    Start-Process $Repo.URL

    git init
    git add *
    git commit -m "Added framework using Plaster Template"
    git remote add origin $Repo.Clone
    git push -u origin master

## Lets write a function to analyse the beards on this page

Start-Process http://tugait.pt/2017/speakers/

## The Get-SpeakerFace function uses the Microsoft Cognative Services Faces API and gets a number of properties for each image

## Run then talk
. 'Presentations:\PSDay - Intro To TDD with Pester\Get-SpeakerFace.ps1'
Copy-Item -Path 'Presentations:\PSDay - Intro To TDD with Pester\Get-SpeakerFace.ps1' -Destination Git:\$ModuleName\functions
git add .\functions\Get-SpeakerFace.ps1
git commit -m "Added Get-SpeakerFace"

$faces = Get-SpeakerFace 
$faces

## Lets look at one of those objects

$faces.Where{$_.Name -eq 'JaapBrasser'} | ConvertTo-Json

