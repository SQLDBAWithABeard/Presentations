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
    DestinationPath = "Git:\BeardModule"
    FullName = "Rob Sewell"
    ModuleName = $ModuleName
    ModuleDesc = $Description
    Version = "0.9.0"
    GitHubUserName = "SQLDBAWithABeard"
    GitHubRepo = "BeardModule"
    }
    If(!(Test-Path $plaster.DestinationPath))
    {
    New-Item -ItemType Directory -Path $plaster.DestinationPath
    }
    Invoke-Plaster @plaster -Verbose

    ## lets have a look what has been created

    cd Git:\BeardModule
    code-insiders . 

    ## Publish to GitHub using this function from Jeff Hicks to create a repo

    . Git:\Functions\New-GitHubRepository.ps1

    $Repo = New-GitHubRepository -Name BeardModule -Description $Description

    Start-Process $Repo.URL

    git init
    git add *
    git commit -m "Added framework using Plaster Template"
    git remote add origin https://github.com/SQLDBAWithABeard/BeardModule.git
    git push -u origin master

    