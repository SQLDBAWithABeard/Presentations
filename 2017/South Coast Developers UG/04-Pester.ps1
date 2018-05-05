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